#!/bin/bash
#
# VOICEVOX Stop Notification Hook
#
# このフックはClaude Codeが停止するたびに呼び出され、
# VOICEVOXまたはmacOS sayコマンドで音声通知します。
#
# Trigger: Stop (Claude Code stops/pauses)
# Output: VOICEVOX speech + macOS notification
#

set -euo pipefail

# ==============================
# Configuration
# ==============================

# VOICEVOX設定
VOICEVOX_HOST="${VOICEVOX_HOST:-localhost}"
VOICEVOX_PORT="${VOICEVOX_PORT:-50021}"
SPEAKER_ID="${VOICEVOX_SPEAKER:-3}"  # 3 = ずんだもん
SPEED="${VOICEVOX_SPEED:-1.2}"

# Fallback settings
USE_MACOS_SAY="${USE_MACOS_SAY:-true}"
SAY_VOICE="${SAY_VOICE:-Kyoko}"

# Queue directory
QUEUE_DIR="/tmp/voicevox_queue"

# ==============================
# Stop Reason Detection
# ==============================

# Claude Code provides these environment variables:
# - STOP_REASON: Why Claude stopped (e.g., "user_input", "end_turn", "tool_use", "max_tokens")
# - STOP_MESSAGE: Additional context about the stop

STOP_REASON="${STOP_REASON:-unknown}"

# ==============================
# Message Generation
# ==============================

generate_stop_message() {
    local reason="$1"

    case "$reason" in
        user_input|end_turn)
            echo "タスクが完了したのだ。次の指示をお待ちしているのだ！"
            ;;
        tool_use)
            echo "ツールの実行待ちなのだ。すぐに戻るのだ！"
            ;;
        max_tokens)
            echo "トークン上限に達したのだ。コンテキストを整理するのがおすすめなのだ！"
            ;;
        error)
            echo "エラーが発生したのだ。確認してほしいのだ！"
            ;;
        *)
            echo "処理が止まったのだ。確認をお願いするのだ！"
            ;;
    esac
}

# ==============================
# VOICEVOX Speech
# ==============================

speak_with_voicevox() {
    local text="$1"

    # Check if VOICEVOX is available
    if ! curl -s --connect-timeout 2 "http://${VOICEVOX_HOST}:${VOICEVOX_PORT}/version" > /dev/null 2>&1; then
        return 1
    fi

    # Generate audio query
    local audio_query
    audio_query=$(curl -s -X POST \
        "http://${VOICEVOX_HOST}:${VOICEVOX_PORT}/audio_query?text=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$text'))")&speaker=${SPEAKER_ID}" \
        -H "Content-Type: application/json" 2>/dev/null)

    if [ -z "$audio_query" ]; then
        return 1
    fi

    # Adjust speed
    audio_query=$(echo "$audio_query" | jq ".speedScale = $SPEED")

    # Synthesize speech and play
    curl -s -X POST \
        "http://${VOICEVOX_HOST}:${VOICEVOX_PORT}/synthesis?speaker=${SPEAKER_ID}" \
        -H "Content-Type: application/json" \
        -d "$audio_query" \
        --output /tmp/stop_speech.wav 2>/dev/null

    if [ -f /tmp/stop_speech.wav ]; then
        afplay /tmp/stop_speech.wav &
        return 0
    fi

    return 1
}

# ==============================
# macOS Say Fallback
# ==============================

speak_with_say() {
    local text="$1"

    if [ "$USE_MACOS_SAY" = "true" ] && command -v say > /dev/null 2>&1; then
        say -v "$SAY_VOICE" "$text" &
        return 0
    fi

    return 1
}

# ==============================
# macOS Notification
# ==============================

send_notification() {
    local message="$1"
    local sound="Glass"

    osascript -e "display notification \"$message\" with title \"Claude Code Stopped\" sound name \"$sound\"" 2>/dev/null || true
}

# ==============================
# Main
# ==============================

main() {
    # Generate message based on stop reason
    local message
    message=$(generate_stop_message "$STOP_REASON")

    # Send macOS notification
    send_notification "$message"

    # Try VOICEVOX first, fallback to macOS say
    if ! speak_with_voicevox "$message"; then
        speak_with_say "$message"
    fi

    # Log
    mkdir -p "$QUEUE_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Stop:$STOP_REASON] $message" >> "$QUEUE_DIR/stop-hook.log"
}

# ==============================
# Execute
# ==============================

# Only run if enabled (default: true)
if [ "${CLAUDE_STOP_SPEAK_ENABLED:-true}" = "true" ]; then
    main
fi

exit 0
