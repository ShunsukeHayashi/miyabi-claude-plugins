# Infinity Sprint ログ監視 + VoiceVox音声通知

Infinity Sprintのログファイルをリアルタイム監視し、特定イベント発生時にVoiceVoxで音声通知を行います。

## 実行内容

以下のBashスクリプトをバックグラウンドで実行してください：

```bash
# 最新のログファイルを取得
LOG_FILE=$(ls -t .ai/logs/infinity-sprint-*.md | head -n 1)

if [[ -z "$LOG_FILE" ]]; then
  echo "❌ Infinity Sprintログファイルが見つかりません (.ai/logs/infinity-sprint-*.md)"
  exit 1
fi

echo "📊 監視開始: $LOG_FILE"
echo "🔊 VoiceVox音声通知: 有効"
echo ""

# VOICEVOX話者ID（デフォルト: ずんだもん）
SPEAKER=${VOICEVOX_SPEAKER:-3}

# ログファイルを監視し、特定の行が追記されたらVoiceVoxを叩く
tail -f "$LOG_FILE" | while read -r line; do
  # "Sprint N" という行を検知
  if [[ "$line" == *"Sprint "* ]]; then
    TEXT_TO_SAY="スプリントが始まるのだ！"
    /voicevox "$TEXT_TO_SAY" $SPEAKER 1.2
    echo "🎤 [VoiceVox] $TEXT_TO_SAY"
  fi

  # "Success" という行を検知
  if [[ "$line" == *": Success"* ]]; then
    TEXT_TO_SAY="やったのだ！タスクが1つ完了したのだ！"
    /voicevox "$TEXT_TO_SAY" $SPEAKER 1.2
    echo "🎤 [VoiceVox] $TEXT_TO_SAY"
  fi

  # "Failed" という行を検知
  if [[ "$line" == *": Failed"* ]]; then
    TEXT_TO_SAY="失敗したのだ！でも諦めないのだ！"
    /voicevox "$TEXT_TO_SAY" $SPEAKER 1.0
    echo "🎤 [VoiceVox] $TEXT_TO_SAY"
  fi

  # "All tasks completed" を検知
  if [[ "$line" == *"All tasks completed"* ]]; then
    TEXT_TO_SAY="全部終わったのだ！お疲れ様なのだ！"
    /voicevox "$TEXT_TO_SAY" $SPEAKER 1.3
    echo "🎤 [VoiceVox] $TEXT_TO_SAY"
  fi
done
```

## 環境変数

- `VOICEVOX_SPEAKER`: VoiceVox話者ID（デフォルト: 3 = ずんだもん）
  - 1: 四国めたん
  - 3: ずんだもん
  - 8: 春日部つむぎ
  - その他: `/voicevox --list-speakers` で確認

## 停止方法

バックグラウンドプロセスを停止する場合：
```bash
pkill -f "tail -f.*infinity-sprint"
```

## 注意事項

- VoiceVox Engineが起動している必要があります
- `/voicevox` コマンドが PATH に存在する必要があります
- ログファイルは `.ai/logs/infinity-sprint-*.md` パターンで検索されます
