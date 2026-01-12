#!/bin/bash
# analyze-paper.sh - Extract structured information from research papers
# Version: 1.0.0
# Part of: Paper2Agent Skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${MIYABI_PAPER2AGENT_CACHE_DIR:-$HOME/.miyabi/paper2agent}"
PDF_PARSER="${MIYABI_PAPER2AGENT_PDF_PARSER:-pdftotext}"

mkdir -p "$CACHE_DIR"

# ============================================================
# Functions
# ============================================================

log() {
  echo "[$(date -Iseconds)] $*" >&2
}

download_paper() {
  local url="$1"
  local output="$2"

  log "Downloading paper from $url"

  if [[ "$url" =~ ^https://arxiv.org/abs/ ]]; then
    # Convert abs URL to PDF URL
    url="${url/\/abs\//\/pdf\/}.pdf"
  fi

  curl -L -o "$output" "$url"
  log "Downloaded to $output"
}

extract_text() {
  local pdf_file="$1"
  local txt_file="$2"

  log "Extracting text from PDF"

  case "$PDF_PARSER" in
    pdftotext)
      if ! command -v pdftotext &>/dev/null; then
        log "ERROR: pdftotext not found. Install: brew install poppler"
        exit 1
      fi
      pdftotext -layout "$pdf_file" "$txt_file"
      ;;
    pypdf)
      python3 <<EOF
from pypdf import PdfReader
reader = PdfReader("$pdf_file")
with open("$txt_file", "w") as f:
    for page in reader.pages:
        f.write(page.extract_text())
EOF
      ;;
    *)
      log "ERROR: Unknown PDF parser: $PDF_PARSER"
      exit 1
      ;;
  esac

  log "Text extracted to $txt_file"
}

extract_section() {
  local text_file="$1"
  local section_name="$2"

  # Try different section header formats
  local patterns=(
    "^${section_name}\$"
    "^${section_name}[[:space:]]*\$"
    "^[0-9]+\.?[[:space:]]*${section_name}"
    "^${section_name}:"
  )

  for pattern in "${patterns[@]}"; do
    local result=$(awk -v pattern="$pattern" '
      BEGIN { capturing = 0; }
      $0 ~ pattern { capturing = 1; next; }
      capturing && /^[A-Z][A-Za-z ]+$/ && !/^(The|A|An|In|For|To|Of)/ { exit; }
      capturing { print; }
    ' "$text_file")

    if [ -n "$result" ]; then
      echo "$result"
      return 0
    fi
  done

  return 1
}

extract_github_urls() {
  local text_file="$1"

  grep -Eo "https://github\.com/[a-zA-Z0-9_-]+/[a-zA-Z0-9_-]+" "$text_file" | sort -u
}

extract_arxiv_id() {
  local text_file="$1"

  # Try to find arXiv ID in various formats
  grep -Eo "arXiv:[0-9]{4}\.[0-9]{4,5}" "$text_file" | head -1 | sed 's/arXiv://'
}

extract_title() {
  local text_file="$1"

  # Take first few lines and find the longest line (likely title)
  head -20 "$text_file" | awk '
    length > max_length { max_length = length; longest = $0; }
    END { print longest; }
  ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

generate_json_output() {
  local title="$1"
  local abstract="$2"
  local methods="$3"
  local github_urls="$4"
  local arxiv_id="$5"

  # Escape JSON strings
  title=$(echo "$title" | jq -R .)
  abstract=$(echo "$abstract" | jq -Rs .)
  methods=$(echo "$methods" | jq -Rs .)

  # Convert GitHub URLs to JSON array
  local github_json="[]"
  if [ -n "$github_urls" ]; then
    github_json=$(echo "$github_urls" | jq -R . | jq -s .)
  fi

  cat <<EOF
{
  "title": $title,
  "arxiv_id": "$(echo "$arxiv_id" | jq -R .)",
  "abstract": $abstract,
  "methods": $methods,
  "code_references": $github_json,
  "extracted_at": "$(date -Iseconds)",
  "parser": "$PDF_PARSER"
}
EOF
}

# ============================================================
# Main Logic
# ============================================================

usage() {
  cat <<EOF
Usage: $0 <paper-url-or-path> [output-json]

Extract structured information from a research paper PDF.

Arguments:
  paper-url-or-path   URL (arXiv, etc.) or local file path
  output-json         Output JSON file (default: stdout)

Environment:
  MIYABI_PAPER2AGENT_CACHE_DIR   Cache directory (default: ~/.miyabi/paper2agent)
  MIYABI_PAPER2AGENT_PDF_PARSER  PDF parser: pdftotext (default) or pypdf

Examples:
  # From arXiv URL
  $0 https://arxiv.org/abs/2509.06917 > analysis.json

  # From local PDF
  $0 ./paper.pdf analysis.json

  # With pypdf parser
  MIYABI_PAPER2AGENT_PDF_PARSER=pypdf $0 paper.pdf
EOF
  exit 1
}

main() {
  if [ $# -lt 1 ]; then
    usage
  fi

  local input="$1"
  local output_json="${2:--}"  # Default to stdout

  local pdf_file
  local is_temp=false

  # Determine if input is URL or file
  if [[ "$input" =~ ^https?:// ]]; then
    # URL - download to cache
    local cache_name=$(echo "$input" | md5sum | cut -d' ' -f1)
    pdf_file="$CACHE_DIR/$cache_name.pdf"

    if [ ! -f "$pdf_file" ]; then
      download_paper "$input" "$pdf_file"
    else
      log "Using cached PDF: $pdf_file"
    fi
  else
    # Local file
    if [ ! -f "$input" ]; then
      log "ERROR: File not found: $input"
      exit 1
    fi
    pdf_file="$input"
  fi

  # Extract text
  local text_file="$CACHE_DIR/$(basename "$pdf_file" .pdf).txt"
  extract_text "$pdf_file" "$text_file"

  # Extract sections
  log "Extracting sections"

  local title=$(extract_title "$text_file")
  log "Title: $title"

  local abstract=$(extract_section "$text_file" "Abstract" || echo "")
  log "Abstract: ${#abstract} chars"

  local methods=$(extract_section "$text_file" "Methods" || \
                  extract_section "$text_file" "Methodology" || \
                  extract_section "$text_file" "Approach" || echo "")
  log "Methods: ${#methods} chars"

  # Extract metadata
  local github_urls=$(extract_github_urls "$text_file" || echo "")
  local github_count=$(echo "$github_urls" | wc -l | tr -d ' ')
  log "GitHub URLs: $github_count found"

  local arxiv_id=$(extract_arxiv_id "$text_file" || echo "")
  log "arXiv ID: $arxiv_id"

  # Generate JSON output
  local json_output=$(generate_json_output "$title" "$abstract" "$methods" "$github_urls" "$arxiv_id")

  if [ "$output_json" = "-" ]; then
    echo "$json_output"
  else
    echo "$json_output" > "$output_json"
    log "Analysis saved to $output_json"
  fi
}

# ============================================================
# Entry Point
# ============================================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
