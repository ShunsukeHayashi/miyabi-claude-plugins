#!/bin/bash
# codex-debug-collect.sh - Debug Collection Hook for Codex Halt Monitor
# Version: 1.0.0
# Description: Collects debug information on crash/halt events

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

DEBUG_ROOT="$PROJECT_ROOT/.ai/debug"
LOG_DIR="$PROJECT_ROOT/.ai/logs"

S3_BUCKET="${MIYABI_DEBUG_S3_BUCKET:-}"

mkdir -p "$DEBUG_ROOT" "$LOG_DIR"

# ============================================================
# Functions
# ============================================================

log() {
  local level="$1"
  shift
  local msg="$*"
  echo "[$(date -Iseconds)] [$level] $msg"
}

collect_system_info() {
  local debug_dir="$1"

  log "INFO" "Collecting system information"

  # System info
  uname -a > "$debug_dir/system-info.txt"

  # macOS version (if applicable)
  if command -v sw_vers &>/dev/null; then
    sw_vers > "$debug_dir/macos-version.txt"
  fi

  # Disk space
  df -h > "$debug_dir/disk-usage.txt"

  # Memory usage
  if command -v vm_stat &>/dev/null; then
    vm_stat > "$debug_dir/memory-usage.txt"
  fi

  # Process info
  ps aux | grep -E "(claude|codex|miyabi)" > "$debug_dir/process-info.txt" || true
}

collect_codex_logs() {
  local debug_dir="$1"

  log "INFO" "Collecting Codex logs"

  # Recent stdout/stderr (if available)
  if [ -f "/tmp/codex-stdout.log" ]; then
    tail -n 200 /tmp/codex-stdout.log > "$debug_dir/stdout-tail-200.log" 2>/dev/null || true
  fi

  if [ -f "/tmp/codex-stderr.log" ]; then
    tail -n 200 /tmp/codex-stderr.log > "$debug_dir/stderr-tail-200.log" 2>/dev/null || true
  fi

  # Codex monitor logs
  if [ -d "$LOG_DIR" ]; then
    find "$LOG_DIR" -name "codex-*.log" -mtime -1 -exec cp {} "$debug_dir/" \; 2>/dev/null || true
  fi
}

collect_git_info() {
  local debug_dir="$1"

  log "INFO" "Collecting Git information"

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    log "WARN" "Not in a Git repository, skipping Git info"
    return
  fi

  # Git status
  git status > "$debug_dir/git-status.txt" 2>&1 || true

  # Recent commits
  git log -10 --oneline > "$debug_dir/git-log.txt" 2>&1 || true

  # Current branch
  git branch --show-current > "$debug_dir/git-branch.txt" 2>&1 || true

  # Worktree list
  git worktree list > "$debug_dir/git-worktrees.txt" 2>&1 || true

  # Uncommitted changes (if any)
  git diff > "$debug_dir/git-diff.txt" 2>&1 || true
}

collect_environment() {
  local debug_dir="$1"

  log "INFO" "Collecting environment variables"

  # Filter sensitive info
  env | grep -E "(MIYABI|CLAUDE|CODEX|PATH|HOME|USER)" | sort > "$debug_dir/environment.txt" || true
}

collect_recent_activity() {
  local debug_dir="$1"

  log "INFO" "Collecting recent activity"

  # Recent commands (from shell history, if accessible)
  if [ -f "$HOME/.bash_history" ]; then
    tail -n 50 "$HOME/.bash_history" > "$debug_dir/recent-commands.txt" 2>/dev/null || true
  fi

  if [ -f "$HOME/.zsh_history" ]; then
    tail -n 50 "$HOME/.zsh_history" > "$debug_dir/recent-commands-zsh.txt" 2>/dev/null || true
  fi
}

create_debug_summary() {
  local debug_dir="$1"
  local meta="$2"

  log "INFO" "Creating debug summary"

  cat > "$debug_dir/SUMMARY.md" <<EOF
# Codex Crash Debug Report

**Generated**: $(date -Iseconds)
**Event ID**: $(echo "$meta" | jq -r '.eventId')
**Severity**: $(echo "$meta" | jq -r '.severity')

---

## Event Details

\`\`\`json
$meta
\`\`\`

---

## Files Collected

$(ls -lh "$debug_dir" | tail -n +2)

---

## System Information

- **OS**: $(uname -s)
- **Version**: $(uname -r)
- **Architecture**: $(uname -m)
- **Hostname**: $(hostname)
- **User**: $(whoami)

---

## Git Information

- **Branch**: $(git branch --show-current 2>/dev/null || echo "N/A")
- **Commit**: $(git rev-parse HEAD 2>/dev/null || echo "N/A")
- **Worktree**: $(git worktree list --porcelain 2>/dev/null | grep '^worktree' | head -1 | cut -d' ' -f2 || echo "none")

---

## Next Steps

1. Review logs in this directory
2. Check \`git-diff.txt\` for uncommitted changes
3. Examine \`stdout-tail-200.log\` and \`stderr-tail-200.log\` for error patterns
4. Verify system resources in \`memory-usage.txt\` and \`disk-usage.txt\`

EOF
}

compress_debug_info() {
  local debug_dir="$1"
  local archive_path="$2"

  log "INFO" "Compressing debug information"

  tar -czf "$archive_path" -C "$(dirname "$debug_dir")" "$(basename "$debug_dir")" 2>/dev/null

  if [ -f "$archive_path" ]; then
    local size=$(du -h "$archive_path" | cut -f1)
    log "INFO" "Debug archive created: $archive_path ($size)"
    return 0
  else
    log "ERROR" "Failed to create debug archive"
    return 1
  fi
}

upload_to_s3() {
  local archive_path="$1"
  local timestamp="$2"

  if [ -z "$S3_BUCKET" ]; then
    log "DEBUG" "S3 upload skipped: MIYABI_DEBUG_S3_BUCKET not set"
    return
  fi

  if ! command -v aws &>/dev/null; then
    log "WARN" "S3 upload skipped: aws CLI not found"
    return
  fi

  log "INFO" "Uploading to S3: s3://$S3_BUCKET/codex-debug/$timestamp.tar.gz"

  aws s3 cp "$archive_path" "s3://$S3_BUCKET/codex-debug/$timestamp.tar.gz" 2>&1

  if [ $? -eq 0 ]; then
    log "INFO" "✅ Uploaded to S3: s3://$S3_BUCKET/codex-debug/$timestamp.tar.gz"
  else
    log "ERROR" "Failed to upload to S3"
  fi
}

# ============================================================
# Main Logic
# ============================================================

main() {
  # Read metadata from stdin
  local meta
  meta=$(cat)

  local event_id=$(echo "$meta" | jq -r '.eventId // "unknown"')
  local timestamp=$(date +%Y%m%d-%H%M%S)

  log "INFO" "Starting debug collection (event_id=$event_id)"

  # Create debug directory
  local debug_dir="$DEBUG_ROOT/codex-crash-$timestamp"
  mkdir -p "$debug_dir"

  # Save metadata
  echo "$meta" | jq '.' > "$debug_dir/event-metadata.json"

  # Collect information
  collect_system_info "$debug_dir"
  collect_codex_logs "$debug_dir"
  collect_git_info "$debug_dir"
  collect_environment "$debug_dir"
  collect_recent_activity "$debug_dir"

  # Create summary
  create_debug_summary "$debug_dir" "$meta"

  # Compress
  local archive_path="$debug_dir.tar.gz"
  if compress_debug_info "$debug_dir" "$archive_path"; then
    # Remove uncompressed directory
    rm -rf "$debug_dir"

    log "INFO" "✅ Debug info collected: $archive_path"
    echo "$archive_path"

    # Upload to S3 (if configured)
    upload_to_s3 "$archive_path" "$timestamp"
  else
    log "ERROR" "Failed to compress debug info, keeping directory: $debug_dir"
    exit 1
  fi

  exit 0
}

# ============================================================
# Entry Point
# ============================================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
