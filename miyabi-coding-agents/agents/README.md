---
name: doc_README
description: Documentation file: README.md
---

# Coding Agent Specifications

コーディング・開発運用系Agentの仕様書ディレクトリです。

## Agent一覧（7個）

### 1. CoordinatorAgent
**タスク統括・並行実行制御Agent**

- **ファイル**: `coordinator-agent.md`
- **権限**: 🔴統括権限
- **役割**: Issue分解、DAG構築、並行実行制御
- **技術**: Kahn's Algorithm、トポロジカルソート、Worktree管理
- **エスカレーション**: TechLead (技術判断)、PO (要件不明確時)

### 2. CodeGenAgent
**AI駆動コード生成Agent**

- **ファイル**: `codegen-agent.md`
- **権限**: 🔵実行権限
- **役割**: TypeScriptコード自動生成、ユニットテスト作成
- **技術**: Claude Sonnet 4、TypeScript strict mode、BaseAgentパターン
- **エスカレーション**: TechLead (アーキテクチャ問題時)

### 3. ReviewAgent
**コード品質判定Agent**

- **ファイル**: `review-agent.md`
- **権限**: 🔵実行権限
- **役割**: 静的解析、セキュリティスキャン、品質スコアリング
- **技術**: ESLint、TypeScript型チェック、100点満点スコア
- **エスカレーション**: TechLead (品質問題時)

### 4. IssueAgent
**Issue分析・Label管理Agent**

- **ファイル**: `issue-agent.md`
- **権限**: 🟢分析権限
- **役割**: Issue分析、53ラベル体系による自動ラベリング
- **技術**: AI推論、キーワードベース判定、依存関係抽出
- **エスカレーション**: PO (要件不明確時)

### 5. PRAgent
**Pull Request自動作成Agent**

- **ファイル**: `pr-agent.md`
- **権限**: 🔵実行権限
- **役割**: PR作成、Conventional Commits準拠
- **技術**: GitHub API、Conventional Commits
- **エスカレーション**: TechLead (コンフリクト時)

### 6. DeploymentAgent
**CI/CDデプロイ自動化Agent**

- **ファイル**: `deployment-agent.md`
- **権限**: 🔵実行権限
- **役割**: Firebase/Vercel/AWSデプロイ、ヘルスチェック
- **技術**: Firebase/Vercel CLI、自動ロールバック
- **エスカレーション**: DevOps (インフラ障害時)

### 7. Hooks Integration
**Claude Code Hooks統合ドキュメント**

- **ファイル**: `hooks-integration.md`
- **役割**: Agent実行時のHook統合、イベント駆動処理
- **技術**: Shell Script、Hook Event Handler

## 権限レベル

| レベル | マーク | 説明 | 該当Agent |
|--------|--------|------|-----------|
| 統括権限 | 🔴 | タスク分解・Agent割り当て・リソース配分を決定可能 | CoordinatorAgent |
| 実行権限 | 🔵 | 直接的な実装・デプロイ・PR作成を実行可能 | CodeGen, Review, PR, Deployment |
| 分析権限 | 🟢 | Issue分析・Label付与・依存関係抽出を実行可能 | IssueAgent |

## 実行フロー

```
┌─────────────────────────────────────────────────────────┐
│ 1. IssueAgent: Issue分析 → Label付与                      │
└──────────────┬──────────────────────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────────────────────┐
│ 2. CoordinatorAgent: Task分解 → DAG構築 → Worktree作成    │
└──────────────┬──────────────────────────────────────────┘
               │
        ┌──────┼──────┐
        │      │      │
        ▼      ▼      ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│ CodeGen  │ │ Review   │ │ Deploy   │
│ (並行)   │ │ (並行)   │ │ (順次)   │
└─────┬────┘ └─────┬────┘ └─────┬────┘
      │            │            │
      └────────────┼────────────┘
                   │
                   ▼
           ┌───────────────┐
           │ PRAgent: PR作成│
           └───────────────┘
```

## 関連ドキュメント

- **実行プロンプト**: [../../prompts/coding/](../../prompts/coding/)
- **Agent運用マニュアル**: [../../../../docs/AGENT_OPERATIONS_MANUAL.md](../../../../docs/AGENT_OPERATIONS_MANUAL.md)
- **Label体系**: [../../../../docs/LABEL_SYSTEM_GUIDE.md](../../../../docs/LABEL_SYSTEM_GUIDE.md)
- **Worktree実行**: [../../../../CLAUDE.md](../../../../CLAUDE.md)

---

🤖 Coding Agent Specifications - Development & Operations Automation
