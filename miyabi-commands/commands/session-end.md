---
description: セッション終了通知 - macOS通知＋牛の鳴き声🐮
---

# セッション終了通知

Agent作業が完了してHuman In The Loopが必要なときに、macOS通知を表示し、牛の鳴き声🐮を鳴らします。

## 実行内容

1. **macOS通知表示**
   - タイトル: "🤖 Miyabi Agent 完了"
   - メッセージ: "Agent作業が完了しました！\nHuman In The Loop が必要です 👋"
   - システム効果音: Purr

2. **牛の鳴き声再生**
   - macOS音声合成（`say`コマンド）で可愛い「もぉ〜🐮💕」を再生
   - 日本語音声（Kyoko）+ 速度調整（-r 220）で明るく可愛い音声

3. **ログ記録**
   - `.ai/logs/YYYY-MM-DD.md` に通知履歴を記録

## 使用方法

### 自動実行（推奨） ✅ 実装済み

**1. セッション終了時に自動実行**
Claude Codeセッション終了時に自動的に通知が鳴ります。
- 設定ファイル: `.claude/settings.local.json`
- フックポイント: `SessionEnd`

**2. キーワード検出で自動実行**
以下のキーワードを入力すると自動的に通知が鳴ります：
- 日本語: 「完了」「終了」「おわり」「セッション終了」「agent完了」「作業完了」
- 英語: 「done」「finish」「complete」「end」「session-end」

例:
```
# Claude Codeで入力
完了
```
→ 自動的に通知🐮が鳴ります！

### 手動実行

**このコマンド:**
```bash
/session-end
```

**直接実行（デバッグ用）:**
```bash
./.codex/hooks/session-end.sh
```

## 出力例

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🤖 Miyabi Agent - Session End Notification
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📱 macOS通知を表示中...
✅ 通知表示成功

   (__)
   (oo)
  /----\
 / |  | \
*  ||--||
   ~~  ~~

🔊 牛の鳴き声を再生中...
✅ 音声再生完了

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🐮 Agent作業完了！次のステップをご確認ください 🐮
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📝 ログ記録完了: .ai/logs/2025-10-22.md
```

## カスタマイズ

### 音声を変更する

**オプション1: 日本語音声・可愛いバージョン（デフォルト）✨**
```bash
say -v Kyoko -r 220 "もぉ〜。もぅ〜。うしさんだよぉ〜"
```

**オプション2: 日本語音声・シンプル版**
```bash
say -v Kyoko -r 200 "もぉ〜。もぉ〜。もぉ〜。"
```

**オプション3: 英語音声・可愛いバージョン**
```bash
say -v Samantha -r 200 "Moo moo! I'm a cute cow!"
```

**オプション4: 英語音声・標準**
```bash
say -v Samantha "Moo. Moo. Moo."
```

**オプション3: システム効果音**
```bash
afplay /System/Library/Sounds/Purr.aiff
```

**オプション4: カスタム音声ファイル**
```bash
# 牛の鳴き声音声ファイルをダウンロードして再生
afplay ./sounds/cow-moo.mp3
```

### 通知メッセージをカスタマイズ

`.codex/hooks/session-end.sh` の以下の行を編集：

```bash
TITLE="🤖 Miyabi Agent 完了"
MESSAGE="Agent作業が完了しました！\nHuman In The Loop が必要です 👋"
SUBTITLE="確認をお願いします"
```

### 通知音を変更

macOSの利用可能な効果音:
- `Basso`
- `Blow`
- `Bottle`
- `Frog`
- `Funk`
- `Glass`
- `Hero`
- `Morse`
- `Ping`
- `Pop`
- `Purr` (デフォルト)
- `Sosumi`
- `Submarine`
- `Tink`

変更方法:
```bash
osascript -e 'display notification "..." with title "..." sound name "Frog"'
```

## トラブルシューティング

### 通知が表示されない

**原因1: 通知権限が無効**
1. システム設定 → 通知
2. ターミナル（または使用中のアプリ）を検索
3. 通知を許可

**原因2: おやすみモード**
1. コントロールセンター → おやすみモード
2. 無効に設定

### 音声が再生されない

**原因1: システム音量がミュート**
```bash
# 音量を50%に設定
osascript -e "set volume output volume 50"
```

**原因2: `say` コマンドが動作しない**
```bash
# テスト実行
say "テスト"

# 音声リスト確認
say -v "?"
```

## 関連ファイル

- `.codex/hooks/session-end.sh` - 通知スクリプト本体
- `.codex/hooks/README.md` - Hooks全体のドキュメント
- `.ai/logs/YYYY-MM-DD.md` - 通知履歴ログ

---

**実行開始:**

このコマンドを実行すると、即座にmacOS通知が表示され、牛の鳴き声🐮が再生されます。
