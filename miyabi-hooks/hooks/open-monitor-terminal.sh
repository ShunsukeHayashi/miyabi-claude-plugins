#!/bin/bash
# Open Monitor Terminal Hook
# Opens a new terminal window attached to the current tmux session for monitoring

set -euo pipefail

# Get current tmux session name
if [ -n "${TMUX:-}" ]; then
    SESSION_NAME=$(tmux display-message -p '#S')
    echo "📍 Current session: $SESSION_NAME"

    # Open new terminal window and attach to same session
    osascript <<EOF
tell application "Terminal"
    activate
    do script "tmux attach-session -t $SESSION_NAME"
end tell
EOF

    echo "✅ Monitor terminal opened for session: $SESSION_NAME"
else
    echo "⚠️ Not in a tmux session. Creating new monitoring session..."

    # Create new session for monitoring
    MONITOR_SESSION="monitor-$(date +%s)"
    tmux new-session -d -s "$MONITOR_SESSION" -c "$PWD"

    osascript <<EOF
tell application "Terminal"
    activate
    do script "tmux attach-session -t $MONITOR_SESSION"
end tell
EOF

    echo "✅ New monitor session created: $MONITOR_SESSION"
fi
