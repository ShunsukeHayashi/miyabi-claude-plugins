# /pattern3 - Pattern 3 Hybrid Orchestration Launcher (Worktree Edition)

**Version**: 2.0.0
**Last Updated**: 2025-10-27
**Category**: Workflow Automation

---

## 📋 Purpose

Pattern 3 Hybrid Orchestrationを起動するコマンド。Main Session（Claude Code）を維持しつつ、Codex XとClaude Code Xを**独立したWorktreeで**バックグラウンド並列実行し、生産性を最大化します。

**生産性向上**: 従来比140%（Main 5タスク + Background 2タスク）
**v2.0新機能**: Git Worktree統合による完全分離と安全な並列実行

---

## 🚀 Usage

```bash
/pattern3
```

実行後、以下のプロンプトに従ってタスクを入力：

1. **Main Task**: Claude Code（このセッション）で実行するメインタスク
2. **Codex X Task**: Zero-bug品質が必要なタスク（テスト、複雑アルゴリズム等）
3. **Claude Code X Task**: 高速実装タスク（ドキュメント、リファクタリング等）

---

## 🎯 Pattern 3とは？

**3セッション並列実行による生産性最大化戦略**

```
Main (Claude Code): 統合・意思決定・レビュー
 ├── Background 1 (Codex X): Zero-bug品質コード
 └── Background 2 (Claude Code X): 高速ドキュメント
```

### 利点
- ✅ Mainタスク中断ゼロ
- ✅ 異なるAIモデルの強み活用
- ✅ コンテキスト分離による並列化
- ✅ 生産性140%向上
- 🆕 **Worktree分離**: Git競合完全回避
- 🆕 **選択的統合**: 成功Sessionのみマージ

### 適切な使用ケース
- 複数の独立タスク
- 異なる品質/速度要求（Zero-bug vs 速度）
- Main中断を避けたい場合
- 🆕 同じファイルを複数Sessionで編集する可能性がある

### 不適切なケース
- タスク間に強依存がある
- 1タスクのみ
- リアルタイムフィードバック必須

---

## 📊 実証済み生産性指標

| 指標 | 従来（順次） | Pattern 3 | 改善率 |
|------|-------------|-----------|--------|
| **並列タスク数** | 1 | 3 | **300%** |
| **総タスク数** | 5 | 7 | **140%** |
| **Main中断回数** | - | 0 | **0回** |

---

## 🔧 実行フロー（v2.0 Worktree Edition）

### Phase 0: 事前チェック ⭐ NEW
```bash
# 1. ブランチ構造確認
git log --oneline --graph --all -10

# 2. 既存実装確認
git status

# 3. Backgroundコマンド検証
codex --version
claude --version
```

### Phase 1: Worktree作成 ⭐ NEW
```bash
# Issue番号取得
ISSUE_NUMBER=575

# Codex X用Worktree作成
git worktree add \
  .worktrees/codex-x-issue-$ISSUE_NUMBER \
  -b feat/codex-x-issue-$ISSUE_NUMBER

# Claude Code X用Worktree作成
git worktree add \
  .worktrees/claude-x-issue-$ISSUE_NUMBER \
  -b feat/claude-x-issue-$ISSUE_NUMBER
```

### Phase 2: Background起動（Worktree内で） ⭐ UPDATED
```bash
# Codex X起動（Worktree内）
cd .worktrees/codex-x-issue-$ISSUE_NUMBER
nohup codex exec --sandbox workspace-write "<Codex X Task>" > /tmp/codex_exec_log.txt 2>&1 &
CODEX_PID=$!
cd ../..

# Claude Code X起動（Worktree内）
cd .worktrees/claude-x-issue-$ISSUE_NUMBER
nohup claude code "<Claude Code X Task>" > /tmp/claude-code-x-log.txt 2>&1 &
CLAUDE_PID=$!
cd ../..
```

### Phase 3: Main実行
Main Taskを実行しつつ、Background進捗を定期監視。
**Main SessionはMain Worktreeで継続** - Background Sessionと完全分離。

### Phase 4: 統合 ⭐ UPDATED
```bash
# Background完了確認
wait $CODEX_PID
CODEX_STATUS=$?

wait $CLAUDE_PID
CLAUDE_STATUS=$?

# Codex X成功時のみマージ
if [ $CODEX_STATUS -eq 0 ]; then
  git merge --no-ff feat/codex-x-issue-$ISSUE_NUMBER -m "feat: Codex X - <task description>"
  git worktree remove .worktrees/codex-x-issue-$ISSUE_NUMBER
else
  echo "⚠️ Codex X failed - Worktree保持（手動確認用）"
fi

# Claude Code X成功時のみマージ
if [ $CLAUDE_STATUS -eq 0 ]; then
  git merge --no-ff feat/claude-x-issue-$ISSUE_NUMBER -m "feat: Claude Code X - <task description>"
  git worktree remove .worktrees/claude-x-issue-$ISSUE_NUMBER
else
  echo "⚠️ Claude Code X failed - Worktree保持（手動確認用）"
fi
```

---

## 📝 Example Session

### Input
```
Main Task: Phase 7-9統合実装とPR作成
Codex X Task: Phase 6-9統合テストの品質向上（proptest追加）
Claude Code X Task: Message Queue統合ドキュメント作成
```

### Output
```
🚀 Pattern 3 Hybrid Orchestration起動

📋 Main Session (Claude Code):
   - Phase 7-9統合実装
   - PR #586作成
   - Master Issue #575更新

🧪 Codex X (PID 64798):
   - proptest依存関係追加
   - Mock Orchestrator設計
   - Property-based testing実装

📄 Claude Code X (PID 65302):
   - Message Queue Architecture Overview
   - Priority Levels詳細ドキュメント
   - Phase 1-9 Message Flow例

✅ 生産性向上: 140% (7タスク vs 5タスク)
```

---

## 🎓 Best Practices（v2.0）

### 1. タスク分割原則
- **Main**: 統合、意思決定、レビュー、最終コミット
- **Codex X (Worktree)**: Zero-bug品質コード、複雑アルゴリズム、セキュリティ
- **Claude Code X (Worktree)**: ドキュメント、リファクタリング、高速実装

### 2. 事前チェック ⭐ NEW
```bash
# Pattern 3起動前に必ず実行
1. ブランチ構造確認（git log --graph）
2. 既存実装確認（git status）
3. Backgroundコマンド検証（codex --version, claude --version）
4. Issue番号確認（gh issue list）
```

### 3. Worktree管理 ⭐ NEW
```bash
# Worktree一覧確認
git worktree list

# Worktree削除（手動）
git worktree remove .worktrees/codex-x-issue-575

# ブランチ削除（Worktree削除後）
git branch -D feat/codex-x-issue-575
```

### 4. 進捗監視
```bash
# Codex X進捗確認
ps -p $CODEX_PID

# Claude Code X進捗確認
ps -p $CLAUDE_PID

# ログ確認
tail -f /tmp/codex_exec_log.txt
tail -f /tmp/claude-code-x-log.txt

# Worktree状態確認
cd .worktrees/codex-x-issue-575 && git status && cd ../..
```

### 5. タイムアウト管理 ⭐ NEW
```bash
# 長時間実行の場合、10分タイムアウト設定
timeout 600 codex exec --sandbox workspace-write "..."

# または定期的な進捗確認
while ps -p $CODEX_PID > /dev/null; do
  echo "Codex X running..."
  sleep 30
done
```

### 6. 選択的統合 ⭐ NEW
Background完了後、**成功Sessionのみマージ**：
```bash
# 成功確認
if [ $CODEX_STATUS -eq 0 ]; then
  echo "✅ Codex X成功 - マージします"
  git merge --no-ff feat/codex-x-issue-575
else
  echo "❌ Codex X失敗 - Worktree保持（手動確認）"
  # Worktreeは削除せず、手動で確認・修正可能
fi
```

---

## 🔗 Related Commands

- `/miyabi-auto`: 単一セッション自動化
- `/miyabi-infinity`: 無限スプリントモード
- `/codex`: Codex X単体実行
- `/claude-code-x`: Claude Code X単体実行

---

## 📖 References

- **Pattern 3実証レポート**: `/tmp/pattern3_final_report.md`
- **Workflow最適化**: `docs/OPTIMAL_MIYABI_WORKFLOW.md`
- **Claude Code X**: `.claude/commands/claude-code-x.md`
- **Codex**: `.claude/commands/codex.md`

---

**このコマンドを実行すると、3セッション並列実行による最高効率のワークフローが起動します。**

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
