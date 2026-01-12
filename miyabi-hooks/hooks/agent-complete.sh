#!/bin/bash
#
# VOICEVOX Agent Completion Narration Hook
#
# このフックはエージェントタスク完了時に呼び出され、
# ズンダモンの音声で完了報告を行います。
#
# Trigger: agent-complete
# Output: VOICEVOX queue (non-blocking)
#

set -euo pipefail

# ==============================
# Configuration
# ==============================

VOICEVOX_ENQUEUE="${VOICEVOX_ENQUEUE:-tools/voicevox_enqueue.sh}"
SPEAKER_ID="${VOICEVOX_SPEAKER:-3}"  # 3 = ずんだもん
SPEED="${VOICEVOX_SPEED:-1.0}"
QUEUE_DIR="/tmp/voicevox_queue"

# ==============================
# Hook Event Data
# ==============================

# Claude Code provides these environment variables:
# - AGENT_TYPE: Type of agent (e.g., "Explore", "general-purpose")
# - AGENT_STATUS: Status (e.g., "success", "failed")
# - AGENT_DESCRIPTION: Description of the task

AGENT_TYPE="${AGENT_TYPE:-unknown}"
STATUS="${AGENT_STATUS:-unknown}"
DESC="${AGENT_DESCRIPTION:-}"

# ==============================
# Narration Text Generation
# ==============================

generate_completion_narration() {
    local agent="$1"
    local status="$2"
    local desc="$3"

    if [ "$status" = "success" ]; then
        if [ -n "$desc" ]; then
            echo "エージェント完了なのだ！${desc}が成功したのだ！次のタスクに進むのだ！"
        else
            echo "${agent}エージェントが完了したのだ！成功なのだ！"
        fi
    else
        if [ -n "$desc" ]; then
            echo "エージェント失敗なのだ…${desc}でエラーが発生したのだ…"
        else
            echo "${agent}エージェントが失敗したのだ…確認が必要なのだ…"
        fi
    fi
}

# ==============================
# Enqueue to VOICEVOX
# ==============================

enqueue_narration() {
    local text="$1"

    # Check if enqueue script exists
    if [ ! -f "$VOICEVOX_ENQUEUE" ]; then
        # Silently skip if VOICEVOX is not available
        return 0
    fi

    # Enqueue narration (non-blocking)
    "$VOICEVOX_ENQUEUE" "$text" "$SPEAKER_ID" "$SPEED" > /dev/null 2>&1 &
}

# ==============================
# Main
# ==============================

main() {
    # Generate narration text
    NARRATION=$(generate_completion_narration "$AGENT_TYPE" "$STATUS" "$DESC")

    # Enqueue to VOICEVOX (background, non-blocking)
    enqueue_narration "$NARRATION"

    # Log to hook log (optional)
    if [ -d "$QUEUE_DIR" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Agent:$AGENT_TYPE] $NARRATION" >> "$QUEUE_DIR/hook.log"
    fi
}

# Run only if VOICEVOX narration is enabled
if [ "${VOICEVOX_NARRATION_ENABLED:-true}" = "true" ]; then
    main
fi

exit 0
