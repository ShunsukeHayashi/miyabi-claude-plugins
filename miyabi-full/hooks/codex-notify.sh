#!/bin/bash
# codex-notify.sh - Notification Hook for Codex Halt Monitor
# Version: 1.0.0
# Description: Sends notifications via macOS, VOICEVOX, and webhooks

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR="$PROJECT_ROOT/.ai/logs"
NOTIFY_LOG="$LOG_DIR/codex-notify-$(date +%Y-%m-%d).log"

WEBHOOK_URL="${MIYABI_WEBHOOK_URL:-}"

mkdir -p "$LOG_DIR"

# ============================================================
# Functions
# ============================================================

log() {
  local level="$1"
  shift
  local msg="$*"
  echo "[$(date -Iseconds)] [$level] $msg" | tee -a "$NOTIFY_LOG"
}

severity_icon() {
  local severity="$1"

  case "$severity" in
    P0) echo "🚨" ;;
    P1) echo "⚠️" ;;
    P2) echo "ℹ️" ;;
    *) echo "📌" ;;
  esac
}

macos_notification() {
  local title="$1"
  local message="$2"

  if command -v osascript &>/dev/null; then
    osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    log "INFO" "macOS notification sent"
  fi
}

voicevox_notification() {
  local text="$1"

  # Check dependencies
  if ! command -v curl &>/dev/null || ! command -v python3 &>/dev/null; then
    log "WARN" "VOICEVOX notification skipped: curl or python3 not found"
    return
  fi

  # Check if VOICEVOX is running
  if ! nc -z 127.0.0.1 50021 2>/dev/null; then
    log "WARN" "VOICEVOX notification skipped: engine not running on port 50021"
    return
  fi

  # Generate audio
  local encoded_text=$(echo "$text" | python3 -c "import sys, urllib.parse; print(urllib.parse.quote(sys.stdin.read()))")

  local query_result=$(curl -s -X POST "http://127.0.0.1:50021/audio_query?text=${encoded_text}&speaker=3")

  echo "$query_result" | curl -s -X POST \
    -H "Content-Type: application/json" \
    -d @- \
    "http://127.0.0.1:50021/synthesis?speaker=3" \
    -o /tmp/codex-notify.wav

  if [ -f /tmp/codex-notify.wav ]; then
    afplay /tmp/codex-notify.wav &>/dev/null &
    log "INFO" "VOICEVOX notification played"
  fi
}

webhook_notification() {
  local payload="$1"

  if [ -z "$WEBHOOK_URL" ]; then
    log "DEBUG" "Webhook notification skipped: MIYABI_WEBHOOK_URL not set"
    return
  fi

  if ! command -v curl &>/dev/null; then
    log "WARN" "Webhook notification skipped: curl not found"
    return
  fi

  local response=$(curl -s -X POST "$WEBHOOK_URL" \
    -H "Content-Type: application/json" \
    -d "$payload")

  log "INFO" "Webhook notification sent to $WEBHOOK_URL"
  log "DEBUG" "Webhook response: $response"
}

# ============================================================
# Main Logic
# ============================================================

main() {
  # Read metadata from stdin
  local meta
  meta=$(cat)

  local reason=$(echo "$meta" | jq -r '.reason // "Unknown event"')
  local severity=$(echo "$meta" | jq -r '.severity // "P2"')
  local details=$(echo "$meta" | jq -c '.details // {}')
  local event_id=$(echo "$meta" | jq -r '.eventId // "unknown"')

  local icon=$(severity_icon "$severity")

  log "INFO" "Notification triggered: $reason (severity=$severity, event_id=$event_id)"

  # ============================================================
  # macOS Notification
  # ============================================================

  macos_notification "$icon Miyabi Codex Monitor" "$reason"

  # ============================================================
  # VOICEVOX Notification
  # ============================================================

  case "$severity" in
    P0)
      voicevox_notification "重大なエラーが発生しました。${reason}"
      ;;
    P1)
      voicevox_notification "警告です。${reason}"
      ;;
    P2)
      voicevox_notification "通知です。${reason}"
      ;;
  esac

  # ============================================================
  # Webhook Notification
  # ============================================================

  local webhook_payload=$(cat <<EOF
{
  "icon": "$icon",
  "severity": "$severity",
  "reason": "$reason",
  "details": $details,
  "eventId": "$event_id",
  "timestamp": "$(date -Iseconds)"
}
EOF
)

  webhook_notification "$webhook_payload"

  # ============================================================
  # Log Details
  # ============================================================

  log "INFO" "Notification details:"
  echo "$meta" | jq '.' >> "$NOTIFY_LOG"

  exit 0
}

# ============================================================
# Entry Point
# ============================================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
