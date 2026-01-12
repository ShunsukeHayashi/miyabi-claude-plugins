#!/bin/bash
# Git Work Logger Script
# Portable version for plugin distribution

ACTION="$1"
TOOL_NAME="$2"
TOOL_INPUT="$3"

LOG_FILE="${MIYABI_LOG_DIR:-/tmp}/miyabi_git_work.log"

log_work() {
  local message="$1"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

case "$ACTION" in
  detect)
    # Detect git operations from bash commands
    if echo "$TOOL_INPUT" | grep -q "git commit"; then
      log_work "COMMIT: $(echo "$TOOL_INPUT" | grep -o '\-m "[^"]*"' | head -1)"
    elif echo "$TOOL_INPUT" | grep -q "git push"; then
      log_work "PUSH: $TOOL_INPUT"
    elif echo "$TOOL_INPUT" | grep -q "gh pr create"; then
      log_work "PR_CREATE: $TOOL_INPUT"
    elif echo "$TOOL_INPUT" | grep -q "gh pr merge"; then
      log_work "PR_MERGE: $TOOL_INPUT"
    fi
    ;;
  report)
    # Show recent work log
    if [ -f "$LOG_FILE" ]; then
      echo "📊 Git Work Log (Last 24h):"
      cat "$LOG_FILE" | tail -20
    else
      echo "No work logged yet"
    fi
    ;;
  *)
    echo "Usage: git_work_logger.sh [detect|report] [tool_name] [tool_input]"
    ;;
esac

exit 0
