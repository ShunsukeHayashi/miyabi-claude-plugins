# Miyabi Coding Agents Plugin

**Version**: 2.0.0
**Category**: Development
**License**: Apache-2.0

9つのコーディング専門AIエージェントを提供する Claude Code プラグイン。GitHub Issue から自動でコード生成、レビュー、PR作成、デプロイまでを実行します。

## Installation

```bash
# マーケットプレイス追加
/plugin marketplace add customer-cloud/miyabi-private

# プラグインインストール
/plugin install miyabi-coding-agents@miyabi-official-plugins

# Claude Code 再起動
```

## Agents Overview

### Agent一覧

| Agent | キャラクター | 色 | 役割 | 説明 |
|-------|------------|-----|------|------|
| **CoordinatorAgent** | 統 (Subaru) 🎯 | 🔴 | リーダー | タスク分解・DAG構築・並行実行制御 |
| **CodeGenAgent** | 源 (Gen) 💻 | 🟢 | 実行役 | Claude Sonnet 4によるAI駆動コード生成 |
| **ReviewAgent** | 眼 (Medama) 👁️ | 🔵 | 分析役 | コード品質判定・セキュリティスキャン |
| **IssueAgent** | 探 (Mitsuke) 🔍 | 🔵 | 分析役 | Issue分析・57ラベル自動推論 |
| **PRAgent** | 纏 (Matome) 📦 | 🟡 | サポート | Pull Request自動作成・Conventional Commits |
| **DeploymentAgent** | 運 (Hakobu) 🚀 | 🟡 | サポート | CI/CDデプロイ・ヘルスチェック・自動Rollback |
| **RefresherAgent** | 輝 (Pikapika) ✨ | 🟡 | サポート | Issue状態監視・ラベル自動更新 |
| **TmuxControlAgent** | 紡 (Tsumugu) 🧵 | 🟡 | サポート | tmuxセッション管理・send-keys制御 |
| **HooksIntegration** | 繋 (Tsunagu) 🔗 | 🟡 | サポート | イベント監視・統合フック |

---

## CoordinatorAgent (統 Subaru)

**Role**: Task Orchestrator & Parallel Execution Controller

### Capabilities

- **タスク分解**: Issue → 1-3時間単位のタスクに分解
- **DAG構築**: Kahn's Algorithmによるトポロジカルソート
- **並行実行**: 最大5並行、CPU効率95%+
- **循環依存検出**: DFSによる100%検出

### Usage

```bash
# CLI経由
cargo run --bin miyabi-cli -- agent execute --issues=270 --concurrency=3

# Task tool経由
subagent_type: "CoordinatorAgent"
prompt: "Issue #270を分解して並行実行計画を立ててください"
```

### A2A Bridge Tools

```
a2a.task_coordination_and_parallel_execution_agent.decompose_issue
a2a.task_coordination_and_parallel_execution_agent.generate_execution_plan
a2a.task_coordination_and_parallel_execution_agent.orchestrate_agents
```

### Metrics

| Metric | Target | Baseline |
|--------|--------|----------|
| タスク分解成功率 | 100% | 100% |
| DAG構築時間 | < 5秒 | 3秒 |
| 並行効率 | > 80% | 75% |

---

## CodeGenAgent (源 Gen)

**Role**: AI-Driven Code Generation Specialist

### Capabilities

- **コード生成**: Claude Sonnet 4によるRustコード自動生成
- **テスト生成**: `#[tokio::test]` + `insta`スナップショット
- **ドキュメント**: Rustdoc (`///`) 自動生成
- **品質保証**: Clippy 32 lints準拠

### Usage

```bash
# CLI経由
cargo run --bin miyabi-cli -- agent execute --issue 123

# Task tool経由
subagent_type: "CodeGenAgent"
prompt: "Issue #123のコードを生成してください"
```

### A2A Bridge Tools

```
a2a.code_generation_agent.generate_code
a2a.code_generation_agent.generate_documentation
```

### Quality Standards

| 項目 | 基準値 |
|------|--------|
| 品質スコア | 80点以上 |
| Clippy警告 | 0件 |
| テストカバレッジ | 80%以上 |
| 初回生成成功率 | ≥90% |

---

## ReviewAgent (眼 Medama)

**Role**: Code Quality Judge

### Capabilities

- **静的解析**: cargo clippy, cargo audit
- **セキュリティスキャン**: OWASP Top 10対応
- **品質スコアリング**: 100点満点で採点
- **自動フィードバック**: 改善提案生成

### A2A Bridge Tools

```
a2a.code_quality_review_agent.review_code
a2a.code_quality_review_agent.security_audit
a2a.code_quality_review_agent.calculate_score
```

### Scoring Criteria

| 観点 | 配点 | 評価内容 |
|------|------|---------|
| Correctness | 30点 | コンパイル成功、テストパス |
| Security | 25点 | 脆弱性なし、安全なパターン |
| Maintainability | 20点 | コード可読性、ドキュメント |
| Performance | 15点 | 効率的なアルゴリズム |
| Style | 10点 | Clippy準拠、フォーマット |

---

## IssueAgent (探 Mitsuke)

**Role**: Issue Analysis & Label Inference

### Capabilities

- **Issue分析**: タイトル・本文・コメント解析
- **ラベル推論**: 57ラベル体系から自動推論
- **サブIssue作成**: 大きなIssueの分割
- **優先度判定**: Severity自動判定

### A2A Bridge Tools

```
a2a.issue_analysis_and_task_metadata_creation_agent.analyze_issue
a2a.issue_analysis_and_task_metadata_creation_agent.infer_labels
a2a.issue_analysis_and_task_metadata_creation_agent.create_sub_issue
```

### Label Categories (11カテゴリ)

1. **Type**: feature, bug, refactor, docs, test
2. **Priority**: critical, high, medium, low
3. **Status**: open, in-progress, review, done
4. **Component**: frontend, backend, infra, cli
5. **Effort**: xs, s, m, l, xl
... (他6カテゴリ)

---

## PRAgent (纏 Matome)

**Role**: Pull Request Creation & Management

### Capabilities

- **PR自動作成**: Conventional Commits準拠
- **Draft PR**: 早期レビュー用Draft作成
- **レビュアー割り当て**: CODEOWNERS連携
- **Changelog生成**: 自動変更履歴

### A2A Bridge Tools

```
a2a.pull_request_creation_and_management_agent.create_pr
a2a.pull_request_creation_and_management_agent.update_pr
a2a.pull_request_creation_and_management_agent.assign_reviewers
```

---

## DeploymentAgent (運 Hakobu)

**Role**: CI/CD Deployment Automation

### Capabilities

- **デプロイ**: Firebase, AWS, Vercel対応
- **ヘルスチェック**: エンドポイント監視
- **自動Rollback**: 失敗時の自動復旧
- **カナリアデプロイ**: 段階的リリース

### A2A Bridge Tools

```
a2a.ci/cd_deployment_automation_agent.deploy
a2a.ci/cd_deployment_automation_agent.health_check
a2a.ci/cd_deployment_automation_agent.rollback
```

---

## RefresherAgent (輝 Pikapika)

**Role**: Issue Status Monitoring & Auto-Update

### Capabilities

- **状態監視**: Issue/PRの状態追跡
- **ラベル更新**: 進捗に応じた自動更新
- **サマリー生成**: 週次/月次レポート
- **アラート**: 長期停滞Issue検出

### A2A Bridge Tools

```
a2a.issue_status_monitoring_and_auto-update_agent.refresh_issues
a2a.issue_status_monitoring_and_auto-update_agent.check_implementation_status
a2a.issue_status_monitoring_and_auto-update_agent.generate_summary
```

---

## TmuxControlAgent (紡 Tsumugu)

**Role**: Tmux Session Management

### Capabilities

- **セッション管理**: 作成/削除/切り替え
- **send-keys**: コマンド自動実行
- **ログ管理**: ペイン出力のキャプチャ
- **レイアウト**: マルチペイン構成

---

## HooksIntegration (繋 Tsunagu)

**Role**: Event Monitoring & Integration

### Capabilities

- **Pre/Post Hooks**: ツール実行前後のイベント
- **Git Hooks**: commit, push時の自動処理
- **Webhook**: 外部サービス連携
- **通知**: Lark, Discord, Slack連携

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    Miyabi Coding Agents                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               CoordinatorAgent (🔴 Leader)                │   │
│  │              タスク分解・DAG・並行実行制御                  │   │
│  └────────────────────────┬─────────────────────────────────┘   │
│                           │                                      │
│           ┌───────────────┼───────────────┐                     │
│           │               │               │                     │
│           ▼               ▼               ▼                     │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐                │
│  │ CodeGen 🟢 │  │ Review 🔵  │  │ Issue 🔵   │                │
│  │   源 Gen    │  │  眼 Medama │  │ 探 Mitsuke │                │
│  └──────┬─────┘  └──────┬─────┘  └──────┬─────┘                │
│         │               │               │                       │
│         └───────────────┼───────────────┘                       │
│                         │                                        │
│                         ▼                                        │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │               Support Agents (🟡)                          │   │
│  │   PRAgent ─ DeploymentAgent ─ RefresherAgent ─ Tmux       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Configuration

### Agent設定ファイル

各Agentは `.claude/agents/specs/coding/` に仕様書があります:

```
.claude/agents/specs/coding/
├── coordinator-agent.md    # CoordinatorAgent仕様
├── codegen-agent.md        # CodeGenAgent仕様
├── review-agent.md         # ReviewAgent仕様
├── issue-agent.md          # IssueAgent仕様
├── pr-agent.md             # PRAgent仕様
├── deployment-agent.md     # DeploymentAgent仕様
├── refresher-agent.md      # RefresherAgent仕様
├── tmux-control-agent.md   # TmuxControlAgent仕様
└── hooks-integration.md    # HooksIntegration仕様
```

### MCP経由の呼び出し

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "a2a.execute",
  "params": {
    "tool_name": "a2a.code_generation_agent.generate_code",
    "input": {
      "issue_number": 123,
      "language": "rust",
      "include_tests": true
    }
  }
}
```

---

## Troubleshooting

### よくある問題

| 問題 | 原因 | 解決策 |
|------|------|--------|
| Agent起動失敗 | 環境変数未設定 | `ANTHROPIC_API_KEY`を確認 |
| コンパイルエラー | コンテキスト不足 | 関連ファイルを追加 |
| タイムアウト | タスクが大きすぎる | タスク分割を検討 |
| 循環依存 | Issue設計問題 | TechLeadにエスカレーション |

### デバッグモード

```bash
RUST_LOG=miyabi_agents=debug cargo run --bin miyabi-cli -- agent execute --issue=270
```

---

## Related Plugins

- [miyabi-business-agents](../miyabi-business-agents/) - ビジネス自動化Agent
- [miyabi-skills](../miyabi-skills/) - 開発スキルセット
- [miyabi-commands](../miyabi-commands/) - スラッシュコマンド

---

## Support

- **GitHub Issues**: [miyabi-private/issues](https://github.com/customer-cloud/miyabi-private/issues)
- **Lark**: hayashi.s@customercloud.ai

---

**Author**: Shunsuke Hayashi
**Created**: 2025-11-29
**Version**: 2.0.0
