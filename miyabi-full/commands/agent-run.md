---
description: Autonomous Agent実行 - Issue自動処理パイプライン (Rust Edition)
---

# Autonomous Agent実行 (🦀 Rust Edition)

GitHub IssueをAutonomous Agentシステムで自動処理します。

**注**: このドキュメントはRust Edition用です。TypeScript版は`docs/legacy/`を参照してください。

## 実行フロー

```
Issue作成/検出
    ↓
CoordinatorAgent（タスク分解・DAG構築）
    ↓ 並行実行（Git Worktree）
├─ IssueAgent（Issue分析・Label付与）
├─ CodeGenAgent（Rustコード生成）
├─ ReviewAgent（品質チェック≥80点）
└─ PRAgent（PR作成）
    ↓
Draft PR作成
    ↓
人間レビュー待ち
```

## 🦀 Rustコマンド

### 単一Issue処理

```bash
# CoordinatorAgentでIssue処理
miyabi agent coordinator --issue 270

# または work-on エイリアス
miyabi work-on 270

# 開発ビルド（デバッグ情報付き）
cargo run --bin miyabi -- agent coordinator --issue 270
```

### 複数Issue並行処理（Worktree）

```bash
# 3つのIssueを並行処理（concurrency: 3）
miyabi parallel --issues 270,271,272 --concurrency 3

# 5つのIssueを並行処理（concurrency: 5）
miyabi parallel --issues 270,271,272,273,274 --concurrency 5

# 開発ビルド
cargo run --bin miyabi -- parallel --issues 270,271,272 --concurrency 3
```

### 個別Agent実行

```bash
# CodeGenAgent（コード生成）
miyabi agent codegen --issue 270

# ReviewAgent（品質レビュー）
miyabi agent review --issue 270

# DeploymentAgent（デプロイ）
miyabi agent deployment --issue 270

# PRAgent（PR作成）
miyabi agent pr --issue 270
```

### ステータス確認

```bash
# プロジェクトステータス表示
miyabi status

# リアルタイム監視
miyabi status --watch

# JSON形式出力（AI Agent統合用）
miyabi status --json
```

## オプション

### `miyabi agent` コマンド

| オプション | 説明 | デフォルト |
|-----------|------|-----------|
| `<AGENT_TYPE>` | Agent種別（coordinator, codegen, review等） | - |
| `--issue <NUMBER>` | Issue番号 | - |

### `miyabi parallel` コマンド

| オプション | 説明 | デフォルト |
|-----------|------|-----------|
| `--issues <N1,N2,...>` | Issue番号（カンマ区切り） | - |
| `--concurrency <N>` | 並行実行数 | 3 |

### グローバルオプション

| オプション | 説明 |
|-----------|------|
| `--json` | JSON形式出力 |
| `-v, --verbose` | 詳細ログ |
| `-h, --help` | ヘルプ表示 |
| `-V, --version` | バージョン表示 |

## 環境変数

必須環境変数:

```bash
# GitHubアクセス
export GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# LLM API（Agent実行時）
export ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# デバイス識別子
export DEVICE_IDENTIFIER="MacBook Pro 16-inch"
```

## 成功条件

✅ **必須**:
- Issue分析完了
- Rustコード生成成功
- 品質スコア ≥80点
- Draft PR作成

✅ **品質**:
- `cargo check` エラー 0件
- `cargo clippy` 警告 0件
- セキュリティスキャン合格（`cargo audit`）
- テストカバレッジ ≥80%

## エスカレーション

以下の場合、自動エスカレーション:

| 条件 | エスカレーション先 | 重要度 |
|------|------------------|--------|
| アーキテクチャ問題 | TechLead | Sev.2-High |
| セキュリティ脆弱性 | CISO | Sev.1-Critical |
| ビジネス優先度 | PO | Sev.3-Medium |
| 循環依存検出 | TechLead | Sev.2-High |

## 実行例

### 例1: 単一Issue処理（Rust Edition）

```bash
$ miyabi agent coordinator --issue 270

✨ Miyabi - 自律型開発フレームワーク

📊 Project Status
  ✅ Miyabi is installed
  ✅ GITHUB_TOKEN is set
  ✅ Git repository detected (main)

🚀 Executing CoordinatorAgent on Issue #270

[CoordinatorAgent] 🔍 Analyzing Issue #270: Add user authentication
[CoordinatorAgent]    Task decomposition: 4 tasks identified
[CoordinatorAgent] 🔗 Building DAG (Directed Acyclic Graph)
[CoordinatorAgent]    Graph: 4 nodes, 3 edges, 3 levels
[CoordinatorAgent] ✅ No circular dependencies

[Worktree] 📁 Creating worktrees for parallel execution
[Worktree]    .worktrees/issue-270-task-1 ✅
[Worktree]    .worktrees/issue-270-task-2 ✅
[Worktree]    .worktrees/issue-270-task-3 ✅
[Worktree]    .worktrees/issue-270-task-4 ✅

[CodeGenAgent] 🧠 Generating Rust code
[CodeGenAgent]    Generated: src/auth/mod.rs
[CodeGenAgent]    Generated: src/auth/user.rs
[CodeGenAgent]    Generated: tests/auth_test.rs

[ReviewAgent] 📊 Quality analysis
[ReviewAgent]    cargo check: ✅ Pass
[ReviewAgent]    cargo clippy: ✅ Pass (0 warnings)
[ReviewAgent]    cargo test: ✅ Pass (15/15 tests)
[ReviewAgent]    Quality Score: 92/100 ✅

[PRAgent] 🚀 Creating Pull Request
[PRAgent] ✅ PR #271 created (Draft)

✅ Issue #270 completed successfully
   Duration: 38,421ms
   Worktrees cleaned up
```

### 例2: 並行処理（3 Issues）

```bash
$ miyabi parallel --issues 270,271,272 --concurrency 3

✨ Miyabi - Parallel Execution

📊 Configuration
  Issues: 270, 271, 272
  Concurrency: 3
  Worktree base: .worktrees/

🚀 Starting parallel execution

[Issue #270] Worktree: .worktrees/issue-270
[Issue #271] Worktree: .worktrees/issue-271
[Issue #272] Worktree: .worktrees/issue-272

[Issue #270] ✅ Completed (PR #280)
[Issue #271] ✅ Completed (PR #281)
[Issue #272] ✅ Completed (PR #282)

📊 Summary
  Total: 3 issues
  Success: 3 (100%)
  Failed: 0
  Total time: 1m 23s
```

### 例3: JSON出力（AI統合用）

```bash
$ miyabi status --json

{
  "installed": true,
  "github_token": true,
  "device_identifier": "MacBook Pro 16-inch",
  "git_repository": true,
  "branch": "main",
  "uncommitted_changes": 0,
  "worktrees": {
    "total": 0,
    "active": 0,
    "idle": 0
  }
}
```

## トラブルシューティング

### API Key エラー

```bash
❌ Error: ANTHROPIC_API_KEY is required for Agent execution

解決策:
1. 環境変数を設定
   export ANTHROPIC_API_KEY=sk-ant-...

2. または ~/.bashrc / ~/.zshrc に追加
   echo 'export ANTHROPIC_API_KEY=sk-ant-...' >> ~/.zshrc
   source ~/.zshrc
```

### GitHub API エラー

```bash
❌ GitHub API error: Not Found (Issue #270)

解決策:
1. Issue番号が正しいか確認
2. GITHUB_TOKEN権限を確認（repo, workflow必須）
3. リポジトリURLが正しいか確認
```

### Rustコンパイルエラー

```bash
❌ cargo check failed (3 errors)

解決策:
1. エラーログを確認: .ai/logs/YYYY-MM-DD.md
2. Clippy推奨を確認: cargo clippy
3. フォーマット修正: cargo fmt
```

### 品質スコア不合格

```bash
❌ Quality score: 65/100 (Failed - Minimum: 80)

エスカレーション:
→ TechLeadにエスカレーション (Sev.2-High)
→ Issue #270にコメント追加
→ Label付与: escalation:tech-lead
```

## ログ確認

```bash
# 実行ログ（Markdown形式）
cat .ai/logs/$(date +%Y-%m-%d).md

# Worktree統計
miyabi worktree list

# Knowledge検索
miyabi knowledge search "CoordinatorAgent execution"

# 統計表示
miyabi knowledge stats
```

## GitHub Actions連携（Rust Edition）

GitHub Actionsから自動実行:

```yaml
- name: Setup Rust
  uses: actions-rs/toolchain@v1
  with:
    toolchain: stable

- name: Build Miyabi CLI
  run: cargo build --release --bin miyabi

- name: Execute CoordinatorAgent
  run: |
    ./target/release/miyabi agent coordinator \
      --issue ${{ github.event.issue.number }}
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
```

## パフォーマンス比較

| 指標 | TypeScript版 | Rust Edition | 改善率 |
|-----|-------------|-------------|--------|
| 実行時間 | 45秒 | 22秒 | **51% faster** ⚡ |
| メモリ使用量 | 450MB | 180MB | **60% reduction** 📉 |
| バイナリサイズ | Node.js必須 | 15MB (単一) | **配布容易** 📦 |
| 起動時間 | 2.5秒 | 0.05秒 | **98% faster** 🚀 |

## 次のステップ

1. **初回セットアップ**
   ```bash
   miyabi setup  # インタラクティブセットアップウィザード
   ```

2. **ステータス確認**
   ```bash
   miyabi status
   ```

3. **Issue処理実行**
   ```bash
   miyabi work-on <ISSUE_NUMBER>
   ```

---

**注**: 実行後、Draft PRが作成されます。人間がレビューして承認してください。

**Rust Edition のメリット**:
- ✅ 50%以上の高速化
- ✅ 30%以上のメモリ削減
- ✅ 単一バイナリ配布
- ✅ コンパイル時型安全性
- ✅ 1,007テスト合格（E2E検証済み）

**ドキュメント**:
- [VERIFICATION_REPORT.md](../../VERIFICATION_REPORT.md) - システム検証レポート
- [E2E_TEST_REPORT.md](../../E2E_TEST_REPORT.md) - E2Eテストレポート
- [RUST_MIGRATION_GUIDE.md](../../docs/RUST_MIGRATION_GUIDE.md) - Rust移行ガイド
