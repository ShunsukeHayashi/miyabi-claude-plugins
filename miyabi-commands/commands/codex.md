# /codex - Codex X バックグラウンド実行

**カテゴリ**: Development Tools
**目的**: Codex X (GPT-5 Codex / o3) をバックグラウンドタスクとして実行

---

## 📋 概要

Codex Xをバックグラウンドで実行し、Claude Codeは並行して他の作業を継続できます。

---

## 🚀 使用方法

```
/codex <instruction>
```

**引数**:
- `instruction`: Codex Xへの詳細な指示（必須）

---

## 🔧 実行内容

以下のBashコマンドをバックグラウンド実行します：

```bash
# Codex Xをバックグラウンドで実行
codex exec --sandbox workspace-write --ask-for-approval on-failure "<instruction>" &

# バックグラウンドタスクIDを記録
CODEX_PID=$!
echo "🚀 Codex X started in background (PID: $CODEX_PID)"
echo "   Instruction: <instruction>"
echo ""
echo "💡 Check progress:"
echo "   - View logs: tail -f ~/.codex/logs/latest.log"
echo "   - Check status: ps -p $CODEX_PID"
echo "   - Wait for completion: wait $CODEX_PID"
```

---

## 📊 実行フロー

```
1. ユーザーが /codex コマンド実行
   ↓
2. Claude Codeが codex exec をバックグラウンド起動
   ↓
3. Claude Codeは他のタスクを継続
   ↓
4. Codex X完了後、ユーザーに通知
```

---

## 💡 使用例

### 例1: リファクタリング（バックグラウンド実行）

```
User: "/codex Refactor miyabi-orchestrator to use async/await throughout"

Claude:
🚀 Codex X started in background (PID: 12345)
   Instruction: Refactor miyabi-orchestrator to use async/await throughout

💡 While Codex X is working, I can help you with other tasks.

   Check progress:
   - tail -f ~/.codex/logs/latest.log
   - wait 12345

What would you like me to do next?
```

### 例2: テスト追加（並行作業）

```
User: "/codex Add comprehensive unit tests for miyabi-agent-core"

Claude:
🚀 Codex X started (PID: 12346)

While Codex X is adding tests, let me review the existing test coverage...

[Claude continues other work]
```

### 例3: Context7 + Codex X

```
User: "/codex with context7: Implement Redis caching layer based on the latest redis-rs documentation"

Claude:
1. [Fetches redis-rs docs via Context7]
2. [Starts Codex X in background with enriched instruction]

🚀 Codex X started (PID: 12347)
   Context: redis-rs v0.25.0 documentation (fetched from Context7)

I'll monitor the progress and notify you when complete.
```

---

## 🔍 進捗確認方法

### 方法1: ログ確認（リアルタイム）

```bash
tail -f ~/.codex/logs/latest.log
```

### 方法2: プロセス確認

```bash
ps -p <PID>
```

### 方法3: 完了待機

```bash
wait <PID>
echo "Codex X completed with exit code: $?"
```

---

## ⚙️ 高度な使用方法

### カスタムモデル指定

```
/codex --model o3 "Optimize database queries in analytics engine"
```

実行されるコマンド:
```bash
codex exec --model o3 --sandbox workspace-write --ask-for-approval on-failure "<instruction>" &
```

### Read-Onlyモード（安全な分析）

```
/codex --sandbox read-only "Analyze codebase for security vulnerabilities"
```

### Full Accessモード（危険、注意）

```
/codex --sandbox danger-full-access "Deploy application to production"
```

---

## 🚨 注意事項

### 1. バックグラウンド実行のリスク

- Codex Xが予期しない変更を加える可能性
- 実行中に競合する変更を加えないよう注意

### 2. リソース使用

- Codex X実行中はCPU/メモリを消費
- 複数のCodex Xタスクを同時実行すると負荷増大

### 3. エラーハンドリング

- バックグラウンドタスクのエラーは即座に通知されない
- ログを定期的に確認する必要がある

---

## 📚 実装詳細

### Bash実装

```bash
#!/bin/bash

# 引数解析
INSTRUCTION="$1"
MODEL="${CODEX_MODEL:-gpt-5-codex}"
SANDBOX="${CODEX_SANDBOX:-workspace-write}"
APPROVAL="${CODEX_APPROVAL:-on-failure}"

# Codex Xバックグラウンド実行
codex exec \
  --model "$MODEL" \
  --sandbox "$SANDBOX" \
  --ask-for-approval "$APPROVAL" \
  "$INSTRUCTION" &

CODEX_PID=$!

# PIDをファイルに保存（追跡用）
echo "$CODEX_PID" > /tmp/codex_latest_pid.txt

# ステータス出力
echo "🚀 Codex X started in background (PID: $CODEX_PID)"
echo "   Model: $MODEL"
echo "   Sandbox: $SANDBOX"
echo "   Instruction: $INSTRUCTION"
echo ""
echo "💡 Monitor progress:"
echo "   tail -f ~/.codex/logs/latest.log"
echo ""
echo "🔍 Check status:"
echo "   ps -p $CODEX_PID"
```

---

## 🎯 次のステップ

### Phase 1: Basic Integration（今すぐ）
- [ ] `/codex` slash command作成
- [ ] バックグラウンド実行テスト
- [ ] ログ監視機能確認

### Phase 2: Advanced Features（今週中）
- [ ] 進捗通知システム（macOS notification）
- [ ] 複数Codex Xタスクの並列実行管理
- [ ] エラー自動検出とリトライ

### Phase 3: Context7 Integration（来週）
- [ ] Context7自動フェッチ
- [ ] Codex Xへのコンテキスト注入
- [ ] 実行結果の品質検証

---

**作成日**: 2025-10-27
**バージョン**: v1.0.0
**カテゴリ**: development, tools, codex, background
**タグ**: #codex #gpt-5 #o3 #background #async
