# /voicevox - VoiceVox音声合成コマンド

**カテゴリ**: ビジネス・コミュニケーション
**目的**: テキストをVOICEVOX音声合成でゆっくり読み上げ

---

## 📋 概要

指定したテキストをVOICEVOX Engineで音声合成し、バックグラウンドキューで再生します。

---

## 🎯 実行内容

以下のBashコマンドを実行してください：

```bash
# ユーザー指定のテキストと話者IDを取得
# デフォルト: speaker=3 (ずんだもん), speed=1.2

# パラメータ例（ユーザーが指定した場合）:
# TEXT="やぁやぁ!完了したのだ!"
# SPEAKER=3
# SPEED=1.2

# スクリプトパス検出（tools/ または /tmp/）
if [ -f "tools/voicevox_enqueue.sh" ]; then
  ENQUEUE_SCRIPT="tools/voicevox_enqueue.sh"
  WORKER_SCRIPT="tools/voicevox_worker.sh"
elif [ -f "/tmp/voicevox_enqueue.sh" ]; then
  ENQUEUE_SCRIPT="/tmp/voicevox_enqueue.sh"
  WORKER_SCRIPT="/tmp/voicevox_worker.sh"
else
  echo "❌ voicevoxスクリプトが見つかりません"
  echo "   tools/voicevox_enqueue.sh または /tmp/voicevox_enqueue.sh を配置してください"
  exit 1
fi

# 実行（パラメータがない場合はデフォルト値を使用）
"$ENQUEUE_SCRIPT" "${TEXT:-テスト音声なのだ}" ${SPEAKER:-3} ${SPEED:-1.2}

# ワーカー起動確認（起動していなければ自動起動）
if ! pgrep -f "voicevox_worker.sh" > /dev/null; then
  echo "🔧 VOICEVOXワーカーを起動します..."
  "$WORKER_SCRIPT" &
  sleep 1
  echo "✅ ワーカー起動完了"
fi

echo ""
echo "🎤 音声合成キューに追加しました"
echo "   テキスト: ${TEXT:-テスト音声なのだ}"
echo "   話者ID: ${SPEAKER:-3}"
echo "   速度: ${SPEED:-1.2}x"
echo ""
echo "📊 キュー状態を確認:"
ls -1 /tmp/voicevox_queue/*.json 2>/dev/null | wc -l | xargs echo "   待機中: "
echo ""
echo "💡 リアルタイムログ確認: tail -f /tmp/voicevox_queue/worker.log"
```

---

## 🚀 使用方法

### 基本実行（デフォルト）

```bash
/voicevox
# → "テスト音声なのだ" をずんだもん (speaker=3) で 1.2倍速再生
```

### カスタムテキスト指定

ユーザーがテキストを指定する場合、Claude Codeに以下のように伝えてください：
```
/voicevox で「やぁやぁ!完了したのだ!」と言わせて
```

### 話者変更

```
/voicevox で四国めたん（speaker=2）で「こんにちは」と言わせて
```

---

## 📖 話者ID一覧

| ID | 名前 | 特徴 |
|----|------|------|
| 2 | 四国めたん | 女性、かわいい |
| 3 | ずんだもん | 女性、元気（デフォルト） |
| 8 | 春日部つむぎ | 女性、明るい |
| 9 | 波音リツ | 女性、落ち着き |

---

## 🔧 前提条件

### 必須
- VOICEVOX Engine起動中（`http://localhost:50021`）
- `/tmp/voicevox_enqueue.sh` 実行可能
- `/tmp/voicevox_worker.sh` 実行可能

### VOICEVOX Engine起動方法

#### Docker版（推奨）
```bash
docker run --rm -p '127.0.0.1:50021:50021' voicevox/voicevox_engine:cpu-latest
```

#### ローカル版
```bash
cd ~/voicevox_engine
python run.py --enable_mock
```

---

## 🐛 トラブルシューティング

### Q: スクリプトが見つからない
```bash
# スクリプトを確認
ls -la tools/voicevox*.sh
ls -la /tmp/voicevox*.sh

# tools/にない場合はGitから取得
git pull origin main

# または /tmp/ から tools/ へコピー
cp /tmp/voicevox_enqueue.sh tools/
cp /tmp/voicevox_worker.sh tools/
chmod +x tools/voicevox*.sh
```

### Q: VOICEVOX Engineに接続できない
```bash
# Engine起動確認
curl http://127.0.0.1:50021/version
```

---

## 📚 関連コマンド

- `/narrate` - Git commitから開発進捗ナレーション生成
- `/watch-sprint` - Infinity Sprintログ監視 + 音声通知
- `/session-end` - セッション終了通知 + 音声ガイド

---

**作成日**: 2025-10-24
**バージョン**: v2.0.0
**カテゴリ**: business, communication, voicevox
**タグ**: #voicevox #tts #audio #notification
