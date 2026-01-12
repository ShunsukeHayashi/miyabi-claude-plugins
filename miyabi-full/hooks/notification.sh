#!/bin/bash
#
# VOICEVOX Task Completion Notification Hook
#
# このフックは作業完了時に呼び出され、
# ズンダモンの音声 + macOS通知でユーザーに報告します。
#
# Trigger: Notification (task completion, errors, user attention needed)
# Output: VOICEVOX queue + macOS notification
#

set -euo pipefail

# ==============================
# Configuration
# ==============================

VOICEVOX_ENQUEUE="${VOICEVOX_ENQUEUE:-tools/voicevox_enqueue.sh}"
SPEAKER_ID="${VOICEVOX_SPEAKER:-3}"  # 3 = ずんだもん
SPEED="${VOICEVOX_SPEED:-1.0}"  # Slower for important notifications
QUEUE_DIR="/tmp/voicevox_queue"

# ==============================
# Hook Event Data
# ==============================

# Claude Code provides these environment variables:
# - NOTIFICATION_TYPE: Type of notification (e.g., "task_complete", "error", "user_input_needed")
# - NOTIFICATION_MESSAGE: Notification message
# - NOTIFICATION_TITLE: Notification title

NOTIFICATION_TYPE="${NOTIFICATION_TYPE:-general}"
MESSAGE="${NOTIFICATION_MESSAGE:-作業が完了しました}"
TITLE="${NOTIFICATION_TITLE:-Claude Code}"

# ==============================
# Narration Text Generation
# ==============================

generate_notification_narration() {
    local type="$1"
    local message="$2"

    case "$type" in
        task_complete)
            echo "やったのだ！「${message}」のタスクが正常に完了したのだ。これは、書かれたコードが意図通りに動いた証拠なのだ。次は何をするか、結果を確認しながら考えてみるのがオススメなのだ！"
            ;;
        error)
            echo "大変なのだ！でも落ち着いてほしいのだ。エラーはプログラミングが上達する最高のチャンスなのだ！「${message}」というメッセージが出ているから、まずはこれをヒントに、どこで問題が起きているか探ってみるのだ。エラーログを見るともっと詳しくわかるはずなのだ！"
            ;;
        user_input_needed)
            echo "プログラムが君に話しかけているのだ！「${message}」について、君からの応答を待っている状態なのだ。これはプログラムが対話的に動いている証拠なのだ。プロンプトの指示を読んで、必要な情報を教えてあげるのだ。"
            ;;
        agent_waiting)
            echo "エージェントの僕、ずんだもんは、今ユーザーさんからの次の指示を待っているのだ。「${message}」の通り、いつでも動ける準備はできているのだ。やってほしいことを教えてくれたら、すぐに実行するのだ！"
            ;;
        *)
            echo "システムからのお知らせなのだ！内容は「${message}」なのだ。プログラムが今どんな状況かを知るための大切な情報だから、一度目を通しておくと、全体の流れがもっと理解しやすくなるのだ！"
            ;;
    esac
}

# ==============================
# macOS Notification
# ==============================

send_macos_notification() {
    local title="$1"
    local message="$2"
    local type="$3"

    # Choose sound based on notification type
    case "$type" in
        error)
            local sound="Basso"
            ;;
        task_complete)
            local sound="Glass"
            ;;
        user_input_needed)
            local sound="Tink"
            ;;
        *)
            local sound="default"
            ;;
    esac

    # Send macOS notification
    osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
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
    NARRATION=$(generate_notification_narration "$NOTIFICATION_TYPE" "$MESSAGE")

    # Send macOS notification
    send_macos_notification "$TITLE" "$MESSAGE" "$NOTIFICATION_TYPE"

    # Enqueue to VOICEVOX (background, non-blocking)
    enqueue_narration "$NARRATION"

    # Log to hook log
    if [ -d "$QUEUE_DIR" ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] [Notification:$NOTIFICATION_TYPE] $NARRATION" >> "$QUEUE_DIR/hook.log"
    fi
}

# Run only if VOICEVOX narration is enabled
if [ "${VOICEVOX_NARRATION_ENABLED:-true}" = "true" ]; then
    main
fi

exit 0
