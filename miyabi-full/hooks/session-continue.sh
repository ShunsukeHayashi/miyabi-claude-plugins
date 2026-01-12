#!/bin/bash
#
# Session Continue Hook - Auto-Continue for Claude Code
#
# This hook monitors tmux sessions and automatically sends "continue" signal
# when Claude Code is waiting for user input.
#
# Usage: This is called by Water Spider Agent automatically
#

SESSION_NAME="$1"

if [ -z "$SESSION_NAME" ]; then
  echo "Usage: $0 <session-name>"
  exit 1
fi

# Check if tmux session exists
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  echo "❌ Session not found: $SESSION_NAME"
  exit 1
fi

# Capture pane content
PANE_CONTENT=$(tmux capture-pane -t "$SESSION_NAME" -p)

# Check for idle indicators
if echo "$PANE_CONTENT" | grep -q "続けますか\|Continue?\|Next?\|Press Enter"; then
  echo "🔄 Detected idle state in $SESSION_NAME"
  echo "📤 Sending continue signal..."

  # Send "続けてください" to session
  tmux send-keys -t "$SESSION_NAME" "続けてください" Enter

  echo "✅ Continue signal sent"
  exit 0
fi

echo "✅ Session is running normally"
exit 0
