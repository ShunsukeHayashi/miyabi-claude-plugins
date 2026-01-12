#!/bin/bash
# VOICEVOX Narrator Script
# Portable version - requires VOICEVOX engine running locally

TOOL_NAME="$1"
TOOL_INPUT="$2"
TOOL_OUTPUT="$3"

# Check if VOICEVOX is available
VOICEVOX_URL="${VOICEVOX_URL:-http://localhost:50021}"

if ! curl -s "$VOICEVOX_URL/version" &>/dev/null; then
  # VOICEVOX not running, skip narration silently
  exit 0
fi

# Generate narration text based on tool
case "$TOOL_NAME" in
  Write|Edit)
    TEXT="ファイルを編集しました"
    ;;
  Bash)
    TEXT="コマンドを実行しました"
    ;;
  Read)
    TEXT="ファイルを読み込みました"
    ;;
  *)
    TEXT="処理が完了しました"
    ;;
esac

# Create audio query
QUERY=$(curl -s -X POST "$VOICEVOX_URL/audio_query?text=$TEXT&speaker=1" -H "Content-Type: application/json")

if [ -n "$QUERY" ]; then
  # Synthesize and play (background, non-blocking)
  curl -s -X POST "$VOICEVOX_URL/synthesis?speaker=1" \
    -H "Content-Type: application/json" \
    -d "$QUERY" \
    --output /tmp/miyabi_narration.wav 2>/dev/null

  # Play audio if afplay available (macOS)
  if command -v afplay &>/dev/null; then
    afplay /tmp/miyabi_narration.wav &>/dev/null &
  fi
fi

exit 0
