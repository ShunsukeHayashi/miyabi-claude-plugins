#!/bin/bash
# extract-code.sh - Extract and analyze codebase from GitHub repositories
# Version: 1.0.0
# Part of: Paper2Agent Skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${MIYABI_PAPER2AGENT_CACHE_DIR:-$HOME/.miyabi/paper2agent}"
CLONE_DIR="$CACHE_DIR/repos"

mkdir -p "$CLONE_DIR"

# ============================================================
# Functions
# ============================================================

log() {
  echo "[$(date -Iseconds)] $*" >&2
}

clone_repository() {
  local repo_url="$1"
  local repo_name="$2"
  local target_dir="$CLONE_DIR/$repo_name"

  if [ -d "$target_dir/.git" ]; then
    log "Repository already cloned: $target_dir"
    log "Updating repository..."
    (cd "$target_dir" && git pull origin main 2>/dev/null || git pull origin master 2>/dev/null || true)
    return 0
  fi

  log "Cloning repository: $repo_url"
  git clone --depth 1 "$repo_url" "$target_dir" 2>&1

  if [ -d "$target_dir" ]; then
    log "✅ Repository cloned to $target_dir"
    return 0
  else
    log "ERROR: Failed to clone repository"
    return 1
  fi
}

detect_language() {
  local repo_dir="$1"

  # Count file extensions
  local py_count=$(find "$repo_dir" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
  local rs_count=$(find "$repo_dir" -name "*.rs" 2>/dev/null | wc -l | tr -d ' ')
  local js_count=$(find "$repo_dir" -name "*.js" -o -name "*.ts" 2>/dev/null | wc -l | tr -d ' ')
  local go_count=$(find "$repo_dir" -name "*.go" 2>/dev/null | wc -l | tr -d ' ')

  log "Language detection: py=$py_count, rs=$rs_count, js=$js_count, go=$go_count"

  if [ "$py_count" -gt 10 ]; then
    echo "python"
  elif [ "$rs_count" -gt 10 ]; then
    echo "rust"
  elif [ "$js_count" -gt 10 ]; then
    echo "javascript"
  elif [ "$go_count" -gt 10 ]; then
    echo "go"
  else
    echo "unknown"
  fi
}

analyze_python_api() {
  local repo_dir="$1"
  local output_file="$2"

  log "Analyzing Python API surface"

  # Find all Python files
  local py_files=$(find "$repo_dir" -name "*.py" -not -path "*/test/*" -not -path "*/tests/*" 2>/dev/null)

  # Extract function signatures using grep/awk
  local functions=$(echo "$py_files" | while read -r file; do
    grep -E "^def [a-zA-Z_]" "$file" 2>/dev/null | head -20 || true
  done)

  # Extract class definitions
  local classes=$(echo "$py_files" | while read -r file; do
    grep -E "^class [a-zA-Z_]" "$file" 2>/dev/null | head -10 || true
  done)

  # Count entry points
  local func_count=$(echo "$functions" | grep -c "^def" || echo "0")
  local class_count=$(echo "$classes" | grep -c "^class" || echo "0")

  log "Found $func_count functions, $class_count classes"

  # Generate JSON output
  cat > "$output_file" <<EOF
{
  "language": "python",
  "repository": "$(basename "$repo_dir")",
  "statistics": {
    "function_count": $func_count,
    "class_count": $class_count
  },
  "sample_functions": [
EOF

  # Add sample functions (first 5)
  local first_func=true
  echo "$functions" | head -5 | while read -r func; do
    if [ -z "$func" ]; then continue; fi

    if [ "$first_func" = true ]; then
      first_func=false
    else
      echo "," >> "$output_file"
    fi

    local func_name=$(echo "$func" | sed 's/def \([^(]*\).*/\1/')
    local signature=$(echo "$func" | sed 's/def //')

    cat >> "$output_file" <<FUNCEOF
    {
      "name": $(echo "$func_name" | jq -R .),
      "signature": $(echo "$signature" | jq -R .),
      "language": "python"
    }
FUNCEOF
  done

  cat >> "$output_file" <<EOF

  ],
  "sample_classes": [
EOF

  # Add sample classes (first 5)
  local first_class=true
  echo "$classes" | head -5 | while read -r cls; do
    if [ -z "$cls" ]; then continue; fi

    if [ "$first_class" = true ]; then
      first_class=false
    else
      echo "," >> "$output_file"
    fi

    local class_name=$(echo "$cls" | sed 's/class \([^(:]*\).*/\1/')

    cat >> "$output_file" <<CLASSEOF
    {
      "name": $(echo "$class_name" | jq -R .),
      "language": "python"
    }
CLASSEOF
  done

  cat >> "$output_file" <<EOF

  ],
  "analyzed_at": "$(date -Iseconds)"
}
EOF

  log "Python API analysis saved to $output_file"
}

analyze_rust_api() {
  local repo_dir="$1"
  local output_file="$2"

  log "Analyzing Rust API surface"

  # Find all Rust files
  local rs_files=$(find "$repo_dir" -name "*.rs" -not -path "*/target/*" 2>/dev/null)

  # Extract public functions
  local pub_fns=$(echo "$rs_files" | while read -r file; do
    grep -E "^pub fn [a-zA-Z_]" "$file" 2>/dev/null | head -20 || true
  done)

  # Extract public structs
  local pub_structs=$(echo "$rs_files" | while read -r file; do
    grep -E "^pub struct [a-zA-Z_]" "$file" 2>/dev/null | head -10 || true
  done)

  local fn_count=$(echo "$pub_fns" | grep -c "^pub fn" || echo "0")
  local struct_count=$(echo "$pub_structs" | grep -c "^pub struct" || echo "0")

  log "Found $fn_count public functions, $struct_count public structs"

  cat > "$output_file" <<EOF
{
  "language": "rust",
  "repository": "$(basename "$repo_dir")",
  "statistics": {
    "public_function_count": $fn_count,
    "public_struct_count": $struct_count
  },
  "sample_functions": [
EOF

  local first=true
  echo "$pub_fns" | head -5 | while read -r func; do
    if [ -z "$func" ]; then continue; fi

    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> "$output_file"
    fi

    cat >> "$output_file" <<FUNCEOF
    {
      "signature": $(echo "$func" | jq -R .),
      "language": "rust"
    }
FUNCEOF
  done

  cat >> "$output_file" <<EOF

  ],
  "analyzed_at": "$(date -Iseconds)"
}
EOF

  log "Rust API analysis saved to $output_file"
}

analyze_generic() {
  local repo_dir="$1"
  local language="$2"
  local output_file="$3"

  log "Performing generic analysis for $language"

  local file_count=$(find "$repo_dir" -type f 2>/dev/null | wc -l | tr -d ' ')
  local readme=$(find "$repo_dir" -maxdepth 2 -iname "README*" 2>/dev/null | head -1)

  cat > "$output_file" <<EOF
{
  "language": "$language",
  "repository": "$(basename "$repo_dir")",
  "statistics": {
    "total_files": $file_count
  },
  "readme_path": "$(echo "${readme:-none}" | jq -R .)",
  "analyzed_at": "$(date -Iseconds)"
}
EOF

  log "Generic analysis saved to $output_file"
}

extract_readme() {
  local repo_dir="$1"
  local output_file="$2"

  local readme=$(find "$repo_dir" -maxdepth 2 -iname "README*" 2>/dev/null | head -1)

  if [ -n "$readme" ]; then
    log "Extracting README: $readme"
    cp "$readme" "$output_file"
    log "README copied to $output_file"
  else
    log "No README found"
    echo "No README found in repository" > "$output_file"
  fi
}

# ============================================================
# Main Logic
# ============================================================

usage() {
  cat <<EOF
Usage: $0 --repo <github-url> [options]

Extract and analyze codebase from GitHub repository.

Options:
  --repo <url>        GitHub repository URL (required)
  --output <file>     Output JSON file (default: stdout)
  --no-clone          Skip cloning, use existing repo in cache

Environment:
  MIYABI_PAPER2AGENT_CACHE_DIR   Cache directory (default: ~/.miyabi/paper2agent)

Examples:
  # Analyze a repository
  $0 --repo https://github.com/user/repo > analysis.json

  # Use cached repository
  $0 --repo https://github.com/user/repo --no-clone
EOF
  exit 1
}

main() {
  local repo_url=""
  local output_json="-"
  local skip_clone=false

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --repo)
        repo_url="$2"
        shift 2
        ;;
      --output)
        output_json="$2"
        shift 2
        ;;
      --no-clone)
        skip_clone=true
        shift
        ;;
      *)
        usage
        ;;
    esac
  done

  if [ -z "$repo_url" ]; then
    log "ERROR: --repo is required"
    usage
  fi

  # Extract repository name from URL
  local repo_name=$(basename "$repo_url" .git)
  log "Repository name: $repo_name"

  local repo_dir="$CLONE_DIR/$repo_name"

  # Clone repository
  if [ "$skip_clone" = false ]; then
    if ! clone_repository "$repo_url" "$repo_name"; then
      log "ERROR: Failed to clone repository"
      exit 1
    fi
  else
    log "Skipping clone, using cached repository"
  fi

  # Detect language
  local language=$(detect_language "$repo_dir")
  log "Detected language: $language"

  # Perform language-specific analysis
  local analysis_file="$CACHE_DIR/${repo_name}-analysis.json"

  case "$language" in
    python)
      analyze_python_api "$repo_dir" "$analysis_file"
      ;;
    rust)
      analyze_rust_api "$repo_dir" "$analysis_file"
      ;;
    *)
      analyze_generic "$repo_dir" "$language" "$analysis_file"
      ;;
  esac

  # Extract README
  local readme_file="$CACHE_DIR/${repo_name}-README.md"
  extract_readme "$repo_dir" "$readme_file"

  # Output result
  if [ "$output_json" = "-" ]; then
    cat "$analysis_file"
  else
    cp "$analysis_file" "$output_json"
    log "Analysis saved to $output_json"
  fi

  log "✅ Codebase extraction complete"
  log "Repository: $repo_dir"
  log "Analysis: $analysis_file"
  log "README: $readme_file"
}

# ============================================================
# Entry Point
# ============================================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
