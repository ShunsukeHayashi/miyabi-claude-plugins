---
name: HooksIntegration
description: Hooks Integration Documentation
type: documentation
subagent_type: "HooksIntegration"
---

# Hook System Integration with Agents

このドキュメントは、各AgentがHook Systemをどのように活用するかを説明します。

## 概要

Hook Systemは、Agent実行のライフサイクルに拡張可能なポイントを提供します：

- **PreHooks**: Agent実行前の検証・セットアップ
- **PostHooks**: Agent実行後のクリーンアップ・通知
- **ErrorHooks**: エラー発生時の処理・リカバリ

## Agent別Hook推奨設定

### CoordinatorAgent

**PreHooks**:
- `EnvironmentCheckHook` - 必須環境変数の確認
- `GitWorkingTreeCheckHook` - ワーキングツリーがクリーンか確認
- `TaskValidationHook` - タスク構造の検証

**PostHooks**:
- `PerformanceTrackingHook` - 実行パフォーマンスの記録
- `ExecutionReportHook` - 実行レポートの生成
- `NotificationHook` - 完了通知（Slack/Discord）

**ErrorHooks**:
- `ErrorReportingHook` - エラー詳細をGitHub Issueにコメント
- `RollbackHook` - DAG構築の巻き戻し

```typescript
import { HookManager, EnvironmentCheckHook, NotificationHook } from './agents/hooks/index.js';

class CoordinatorAgent extends BaseAgent {
  constructor(config: AgentConfig) {
    super('CoordinatorAgent', config);

    const hookManager = new HookManager();

    // PreHooks
    hookManager.registerPreHook(
      new EnvironmentCheckHook(['GITHUB_TOKEN', 'DEVICE_IDENTIFIER'])
    );

    // PostHooks
    hookManager.registerPostHook(
      new NotificationHook({
        slackWebhookUrl: process.env.SLACK_WEBHOOK_URL,
        notifyOnSuccess: true,
      })
    );

    this.setHookManager(hookManager);
  }
}
```

### CodeGenAgent

**PreHooks**:
- `EnvironmentCheckHook` - ANTHROPIC_API_KEY の確認
- `DependencyCheckHook` - 依存タスクの完了確認
- `WorktreePre Hook` - Worktree環境の確認

**PostHooks**:
- `CodeQualityCheckHook` - 生成コードの品質チェック
- `TestRunnerHook` - 自動テスト実行
- `ArtifactArchiveHook` - 生成物のアーカイブ
- `CleanupHook` - 一時ファイルのクリーンアップ

**ErrorHooks**:
- `CodeGenErrorHook` - コード生成エラーの詳細記録
- `EscalationHook` - TechLeadへのエスカレーション

```typescript
class CodeGenAgent extends BaseAgent {
  constructor(config: AgentConfig) {
    super('CodeGenAgent', config);

    const hookManager = new HookManager();

    // PreHooks
    hookManager.registerPreHook(
      new EnvironmentCheckHook(['ANTHROPIC_API_KEY', 'GITHUB_TOKEN'])
    );
    hookManager.registerPreHook(
      new DependencyCheckHook(config.reportDirectory)
    );

    // PostHooks
    hookManager.registerPostHook(
      new CleanupHook({
        tempDirs: ['.temp/codegen', '.cache/anthropic'],
      })
    );

    this.setHookManager(hookManager);
  }
}
```

### ReviewAgent

**PreHooks**:
- `EnvironmentCheckHook` - 環境変数確認
- `CodeAvailabilityHook` - レビュー対象コードの存在確認

**PostHooks**:
- `QualityScoreHook` - 品質スコアの記録
- `LabelUpdateHook` - GitHub Issueのラベル更新
- `NotificationHook` - レビュー完了通知

**ErrorHooks**:
- `ReviewErrorHook` - レビューエラーの記録

```typescript
class ReviewAgent extends BaseAgent {
  constructor(config: AgentConfig) {
    super('ReviewAgent', config);

    const hookManager = new HookManager();

    // PreHooks
    hookManager.registerPreHook(
      new EnvironmentCheckHook(['GITHUB_TOKEN'])
    );

    // PostHooks
    hookManager.registerPostHook(
      new NotificationHook({
        slackWebhookUrl: process.env.SLACK_WEBHOOK_URL,
        notifyOnSuccess: true,
        notifyOnFailure: true,
      })
    );

    this.setHookManager(hookManager);
  }
}
```

### IssueAgent

**PreHooks**:
- `EnvironmentCheckHook` - GITHUB_TOKEN確認
- `RateLimitCheckHook` - GitHub API rate limitチェック

**PostHooks**:
- `LabelApplicationHook` - 53ラベルの適用
- `AssigneeUpdateHook` - 担当者の自動アサイン
- `AnalysisCommentHook` - 分析結果コメント投稿

**ErrorHooks**:
- `IssueAnalysisErrorHook` - 分析エラーの記録

```typescript
class IssueAgent extends BaseAgent {
  constructor(config: AgentConfig) {
    super('IssueAgent', config);

    const hookManager = new HookManager();

    // PreHooks
    hookManager.registerPreHook(
      new EnvironmentCheckHook(['GITHUB_TOKEN'])
    );

    // PostHooks
    hookManager.registerPostHook(
      new CleanupHook({
        tempFiles: ['.temp/issue-analysis.json'],
      })
    );

    this.setHookManager(hookManager);
  }
}
```

### PRAgent

**PreHooks**:
- `EnvironmentCheckHook` - GITHUB_TOKEN確認
- `GitBranchCheckHook` - ブランチの存在確認
- `ConventionalCommitsCheckHook` - コミットメッセージ検証

**PostHooks**:
- `PRCreationHook` - PR作成
- `ReviewerAssignmentHook` - レビュアーアサイン
- `NotificationHook` - PR作成通知

**ErrorHooks**:
- `PRErrorHook` - PR作成エラーの記録

```typescript
class PRAgent extends BaseAgent {
  constructor(config: AgentConfig) {
    super('PRAgent', config);

    const hookManager = new HookManager();

    // PreHooks
    hookManager.registerPreHook(
      new EnvironmentCheckHook(['GITHUB_TOKEN'])
    );

    // PostHooks
    hookManager.registerPostHook(
      new NotificationHook({
        slackWebhookUrl: process.env.SLACK_WEBHOOK_URL,
        discordWebhookUrl: process.env.DISCORD_WEBHOOK_URL,
        notifyOnSuccess: true,
      })
    );

    this.setHookManager(hookManager);
  }
}
```

### DeploymentAgent

**PreHooks**:
- `EnvironmentCheckHook` - デプロイ用環境変数確認
- `BuildCheckHook` - ビルド成功確認
- `TestPassCheckHook` - テスト成功確認
- `BackupHook` - 現在のデプロイ状態をバックアップ

**PostHooks**:
- `HealthCheckHook` - デプロイ後のヘルスチェック
- `RollbackPreparationHook` - ロールバック用情報記録
- `NotificationHook` - デプロイ完了通知

**ErrorHooks**:
- `AutoRollbackHook` - 自動ロールバック
- `IncidentReportHook` - インシデントレポート作成
- `EscalationHook` - DevOps/CTOへエスカレーション

```typescript
class DeploymentAgent extends BaseAgent {
  constructor(config: AgentConfig) {
    super('DeploymentAgent', config);

    const hookManager = new HookManager();

    // PreHooks
    hookManager.registerPreHook(
      new EnvironmentCheckHook([
        'FIREBASE_TOKEN',
        'VERCEL_TOKEN',
        'AWS_ACCESS_KEY_ID',
        'AWS_SECRET_ACCESS_KEY',
      ])
    );

    // PostHooks
    hookManager.registerPostHook(
      new NotificationHook({
        slackWebhookUrl: process.env.SLACK_WEBHOOK_URL,
        notifyOnSuccess: true,
        notifyOnFailure: true,
        mentionOnFailure: ['devops', 'cto'],
      })
    );

    // ErrorHooks
    hookManager.registerErrorHook(
      new AutoRollbackHook()
    );

    this.setHookManager(hookManager);
  }
}
```

## Hook Priority ベストプラクティス

### PreHooks

```
Priority 0-10:   Critical validation (環境、権限)
Priority 10-20:  Dependency checks
Priority 20-50:  Setup and preparation
Priority 50-100: Custom business logic
```

### PostHooks

```
Priority 0-50:   Data processing, metrics recording
Priority 50-80:  Artifact archiving
Priority 80-90:  Notifications
Priority 90-100: Cleanup
```

## Hook 実装ガイドライン

### 1. PreHookは失敗時にブロック

PreHookが失敗した場合、デフォルトでAgent実行をブロックします：

```typescript
hookManager.registerPreHook(
  new CriticalCheckHook(),
  { continueOnFailure: false } // Default: block on failure
);
```

### 2. PostHookは失敗しても継続

PostHookが失敗してもAgent実行結果は保持されます：

```typescript
hookManager.registerPostHook(
  new OptionalNotificationHook(),
  { continueOnFailure: true } // Continue even if notification fails
);
```

### 3. Timeoutを設定

長時間実行されるHookにはタイムアウトを設定：

```typescript
hookManager.registerPreHook(
  new SlowValidationHook(),
  { timeout: 30000 } // 30 second timeout
);
```

### 4. 並列実行でパフォーマンス向上

PostHooksは並列実行可能：

```typescript
hookManager.registerPostHook(
  new NotificationHook({ ... }),
  { runInBackground: true } // Non-blocking
);

hookManager.registerPostHook(
  new MetricsHook({ ... }),
  { runInBackground: true } // Non-blocking
);
```

## トラブルシューティング

### Hook実行の確認

```typescript
const registeredHooks = hookManager.getRegisteredHooks();
console.log('PreHooks:', registeredHooks.preHooks);
console.log('PostHooks:', registeredHooks.postHooks);
console.log('ErrorHooks:', registeredHooks.errorHooks);
```

### Hook実行ログの確認

```bash
DEBUG=hooks npm run agents:parallel:exec -- --issues=270
```

### Hook実行結果の取得

```typescript
const preHookResults = await hookManager.executePreHooks(context);

preHookResults.forEach((result) => {
  console.log(`${result.hookName}: ${result.status} (${result.durationMs}ms)`);
  if (result.error) {
    console.error(`Error: ${result.error}`);
  }
});
```

## 関連ドキュメント

- [Hook System README](../../agents/hooks/README.md) - Hook Systemの詳細
- [BaseAgent](../../agents/base-agent.ts) - BaseAgentの実装
- [Hook Examples](../../agents/hooks/examples/) - 使用例

---

🤖 Generated with Claude Code
