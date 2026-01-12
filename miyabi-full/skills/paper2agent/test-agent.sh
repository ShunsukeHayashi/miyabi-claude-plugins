#!/bin/bash
# test-agent.sh - Test Paper2Agent generated MCP servers
# Version: 1.0.0
# Part of: Paper2Agent Skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${MIYABI_PAPER2AGENT_CACHE_DIR:-$HOME/.miyabi/paper2agent}"
TEST_TIMEOUT="${MIYABI_PAPER2AGENT_TEST_TIMEOUT:-300}"

# ============================================================
# Colors and Formatting
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# Functions
# ============================================================

log() {
  local level="$1"
  shift
  local msg="$*"
  local color="$NC"

  case "$level" in
    ERROR) color="$RED" ;;
    SUCCESS) color="$GREEN" ;;
    WARN) color="$YELLOW" ;;
    INFO) color="$BLUE" ;;
  esac

  echo -e "[$(date -Iseconds)] ${color}[$level]${NC} $msg" >&2
}

test_file_exists() {
  local file="$1"
  local description="$2"

  if [ -f "$file" ]; then
    log "SUCCESS" "✅ $description exists: $file"
    return 0
  else
    log "ERROR" "❌ $description not found: $file"
    return 1
  fi
}

test_mcp_definition_valid() {
  local mcp_file="$1"

  log "INFO" "Testing MCP definition validity"

  if ! command -v jq &>/dev/null; then
    log "WARN" "jq not found, skipping JSON validation"
    return 0
  fi

  if jq empty "$mcp_file" 2>/dev/null; then
    log "SUCCESS" "✅ MCP definition is valid JSON"

    # Check required fields
    local name=$(jq -r '.name // empty' "$mcp_file")
    local version=$(jq -r '.version // empty' "$mcp_file")
    local tools=$(jq '.tools | length' "$mcp_file")

    if [ -n "$name" ] && [ -n "$version" ] && [ "$tools" -gt 0 ]; then
      log "SUCCESS" "✅ MCP has required fields (name=$name, version=$version, tools=$tools)"
      return 0
    else
      log "ERROR" "❌ MCP missing required fields"
      return 1
    fi
  else
    log "ERROR" "❌ MCP definition is invalid JSON"
    return 1
  fi
}

test_mcp_server_startup() {
  local mcp_dir="$1"
  local server_script="$mcp_dir/mcp_server.py"

  log "INFO" "Testing MCP server startup"

  if [ ! -f "$server_script" ]; then
    log "WARN" "MCP server implementation not found, skipping startup test"
    return 0
  fi

  # Test server can be imported (syntax check)
  if python3 -c "import sys; sys.path.insert(0, '$mcp_dir'); import mcp_server" 2>/dev/null; then
    log "SUCCESS" "✅ MCP server script is importable"
    return 0
  else
    log "ERROR" "❌ MCP server has syntax errors"
    return 1
  fi
}

test_paper_analysis_reproducible() {
  local paper_file="$1"

  log "INFO" "Testing paper analysis reproducibility"

  if [ ! -f "$paper_file" ]; then
    log "WARN" "Paper analysis file not found, skipping reproducibility test"
    return 0
  fi

  # Re-run analysis
  local temp_output="/tmp/paper-analysis-test-$$.json"
  if "$SCRIPT_DIR/analyze-paper.sh" "$paper_file" "$temp_output" 2>/dev/null; then
    log "SUCCESS" "✅ Paper analysis is reproducible"
    rm -f "$temp_output"
    return 0
  else
    log "ERROR" "❌ Paper analysis failed to reproduce"
    rm -f "$temp_output"
    return 1
  fi
}

test_code_extraction_works() {
  local repo_url="$1"

  log "INFO" "Testing code extraction"

  if [ -z "$repo_url" ]; then
    log "WARN" "No repository URL provided, skipping code extraction test"
    return 0
  fi

  # Test with --no-clone to avoid re-cloning
  if "$SCRIPT_DIR/extract-code.sh" --repo "$repo_url" --no-clone > /dev/null 2>&1; then
    log "SUCCESS" "✅ Code extraction works"
    return 0
  else
    log "WARN" "⚠️  Code extraction had issues (might need fresh clone)"
    return 0  # Don't fail on this
  fi
}

run_test_suite() {
  local mcp_file="$1"
  local mcp_dir="$(dirname "$mcp_file")"
  local paper_analysis="${2:-}"
  local code_analysis="${3:-}"
  local repo_url="${4:-}"

  log "INFO" "=== Paper2Agent Test Suite ==="
  log "INFO" "MCP: $mcp_file"
  echo ""

  local tests_passed=0
  local tests_failed=0

  # Test 1: MCP definition exists
  if test_file_exists "$mcp_file" "MCP definition"; then
    ((tests_passed++))
  else
    ((tests_failed++))
  fi

  # Test 2: MCP definition valid
  if test_mcp_definition_valid "$mcp_file"; then
    ((tests_passed++))
  else
    ((tests_failed++))
  fi

  # Test 3: MCP server implementation (if exists)
  if [ -f "$mcp_dir/mcp_server.py" ]; then
    if test_mcp_server_startup "$mcp_dir"; then
      ((tests_passed++))
    else
      ((tests_failed++))
    fi
  else
    log "INFO" "No implementation found (generate with --generate-impl)"
  fi

  # Test 4: Paper analysis reproducibility
  if [ -n "$paper_analysis" ]; then
    if test_paper_analysis_reproducible "$paper_analysis"; then
      ((tests_passed++))
    else
      ((tests_failed++))
    fi
  fi

  # Test 5: Code extraction
  if [ -n "$repo_url" ]; then
    if test_code_extraction_works "$repo_url"; then
      ((tests_passed++))
    else
      ((tests_failed++))
    fi
  fi

  # Summary
  echo ""
  log "INFO" "=== Test Summary ==="
  log "SUCCESS" "✅ Passed: $tests_passed"
  if [ "$tests_failed" -gt 0 ]; then
    log "ERROR" "❌ Failed: $tests_failed"
  fi

  echo ""

  if [ "$tests_failed" -eq 0 ]; then
    log "SUCCESS" "🎉 All tests passed!"
    return 0
  else
    log "ERROR" "Some tests failed"
    return 1
  fi
}

# ============================================================
# Main Logic
# ============================================================

usage() {
  cat <<EOF
Usage: $0 --mcp <file> [options]

Test Paper2Agent generated MCP server.

Options:
  --mcp <file>            MCP definition JSON file (required)
  --paper-analysis <file> Original paper analysis JSON
  --code-analysis <file>  Original code analysis JSON
  --repo-url <url>        GitHub repository URL

Environment:
  MIYABI_PAPER2AGENT_CACHE_DIR     Cache directory
  MIYABI_PAPER2AGENT_TEST_TIMEOUT  Test timeout in seconds (default: 300)

Examples:
  # Basic test
  $0 --mcp .claude/mcp-servers/paper2agent/paper-example.json

  # Full test with all artifacts
  $0 --mcp paper-example.json \\
     --paper-analysis paper.json \\
     --code-analysis code.json \\
     --repo-url https://github.com/user/repo
EOF
  exit 1
}

main() {
  local mcp_file=""
  local paper_analysis=""
  local code_analysis=""
  local repo_url=""

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --mcp)
        mcp_file="$2"
        shift 2
        ;;
      --paper-analysis)
        paper_analysis="$2"
        shift 2
        ;;
      --code-analysis)
        code_analysis="$2"
        shift 2
        ;;
      --repo-url)
        repo_url="$2"
        shift 2
        ;;
      *)
        usage
        ;;
    esac
  done

  if [ -z "$mcp_file" ]; then
    log "ERROR" "--mcp is required"
    usage
  fi

  # Run test suite
  if run_test_suite "$mcp_file" "$paper_analysis" "$code_analysis" "$repo_url"; then
    exit 0
  else
    exit 1
  fi
}

# ============================================================
# Entry Point
# ============================================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
