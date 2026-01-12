#!/bin/bash
# Agent Event Hook
# Sends agent execution events to Miyabi Dashboard
#
# Usage:
#   ./agent-event.sh <event_type> <agent_id> <issue_number> [options]
#
# Examples:
#   ./agent-event.sh started coordinator 47 '{"taskId":"TASK-001","priority":"P0"}'
#   ./agent-event.sh progress codegen 58 50 "Generating components"
#   ./agent-event.sh completed review 47 '{"success":true,"qualityScore":95}'
#   ./agent-event.sh error issue 47 "Failed to parse"

set -e

# Configuration
DASHBOARD_URL="${DASHBOARD_URL:-http://localhost:3001}"
ENDPOINT="$DASHBOARD_URL/api/agent-event"

# Parse arguments
EVENT_TYPE="$1"
AGENT_ID="$2"
ISSUE_NUMBER="$3"
shift 3

# Build JSON payload based on event type
case "$EVENT_TYPE" in
  started)
    PARAMETERS="${1:-{}}"
    PAYLOAD=$(cat <<EOF
{
  "eventType": "started",
  "agentId": "$AGENT_ID",
  "issueNumber": $ISSUE_NUMBER,
  "parameters": $PARAMETERS
}
EOF
)
    ;;

  progress)
    PROGRESS="${1:-0}"
    MESSAGE="${2:-}"
    PAYLOAD=$(cat <<EOF
{
  "eventType": "progress",
  "agentId": "$AGENT_ID",
  "issueNumber": $ISSUE_NUMBER,
  "progress": $PROGRESS,
  "message": "$MESSAGE"
}
EOF
)
    ;;

  completed)
    RESULT="${1:-{\"success\":true}}"
    PAYLOAD=$(cat <<EOF
{
  "eventType": "completed",
  "agentId": "$AGENT_ID",
  "issueNumber": $ISSUE_NUMBER,
  "result": $RESULT
}
EOF
)
    ;;

  error)
    ERROR_MSG="${1:-Unknown error}"
    PAYLOAD=$(cat <<EOF
{
  "eventType": "error",
  "agentId": "$AGENT_ID",
  "issueNumber": $ISSUE_NUMBER,
  "error": "$ERROR_MSG"
}
EOF
)
    ;;

  *)
    echo "❌ Unknown event type: $EVENT_TYPE" >&2
    echo "Valid types: started, progress, completed, error" >&2
    exit 1
    ;;
esac

# Send to dashboard (silently, don't block on failure)
curl -s -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  >/dev/null 2>&1 || true

# Log for debugging (optional)
if [[ "${DEBUG:-}" == "1" ]]; then
  echo "📡 Agent event sent: $EVENT_TYPE - $AGENT_ID on #$ISSUE_NUMBER" >&2
fi
