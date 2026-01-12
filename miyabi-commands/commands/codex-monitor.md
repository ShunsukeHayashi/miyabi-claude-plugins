# Codex Background Task Monitoring System

## Overview
Codexバックグラウンドタスクの進捗を監視し、結果を収集するモニタリングシステム

## Monitoring Architecture

### 1. Task Status Tracking
```bash
# タスクステータスファイル構造
.ai/codex-tasks/
├── <task-id>/
│   ├── status.json          # タスク状態
│   ├── instructions.md      # 実行指示
│   ├── progress.log         # 進捗ログ
│   ├── results.json         # 実行結果
│   └── artifacts/           # 生成物
│       ├── pr-reviews/      # PRレビュー結果
│       └── reports/         # レポート
```

### 2. Status Schema
```json
{
  "task_id": "codex-pr-review-2025-10-31",
  "type": "pr_review",
  "status": "in_progress | completed | failed",
  "created_at": "2025-10-31T11:50:00Z",
  "updated_at": "2025-10-31T12:00:00Z",
  "progress": {
    "total": 19,
    "completed": 5,
    "percentage": 26.3
  },
  "results": {
    "approved": 3,
    "changes_requested": 1,
    "commented": 1
  },
  "pid": 12345,
  "log_file": ".ai/codex-tasks/codex-pr-review-2025-10-31/progress.log"
}
```

### 3. Monitoring Commands

#### Start Task with Monitoring
```bash
./scripts/codex-task-runner.sh start \
  --task-id "codex-pr-review-2025-10-31" \
  --instructions "/tmp/codex_pr_review_instructions.md" \
  --type "pr_review"
```

#### Monitor Progress
```bash
# リアルタイム監視
./scripts/codex-task-runner.sh monitor "codex-pr-review-2025-10-31"

# ステータス確認
./scripts/codex-task-runner.sh status "codex-pr-review-2025-10-31"

# ログ表示
./scripts/codex-task-runner.sh logs "codex-pr-review-2025-10-31" --follow
```

#### Get Results
```bash
# 結果取得
./scripts/codex-task-runner.sh results "codex-pr-review-2025-10-31"

# レポート生成
./scripts/codex-task-runner.sh report "codex-pr-review-2025-10-31" --format markdown
```

### 4. Real-time Dashboard (TUI)

```
╔══════════════════════════════════════════════════════════════╗
║ Codex Task Monitor - codex-pr-review-2025-10-31             ║
╠══════════════════════════════════════════════════════════════╣
║ Status: IN_PROGRESS                                          ║
║ Started: 2025-10-31 11:50:00                                 ║
║ Elapsed: 00:10:23                                            ║
╠══════════════════════════════════════════════════════════════╣
║ Progress: [████████░░░░░░░░░░] 5/19 (26.3%)                  ║
║                                                              ║
║ Completed PRs:                                               ║
║   ✅ #626 - toml upgrade (APPROVED)                          ║
║   ✅ #625 - clap upgrade (APPROVED)                          ║
║   ✅ #607 - indicatif upgrade (APPROVED)                     ║
║   ⚠️  #604 - petgraph upgrade (CHANGES_REQUESTED)           ║
║   💬 #603 - config upgrade (COMMENTED)                       ║
║                                                              ║
║ Current: Reviewing PR #602 - crossterm upgrade               ║
║                                                              ║
║ Last Log Entry (11:59:45):                                   ║
║   > Running: gh pr diff 602                                  ║
╠══════════════════════════════════════════════════════════════╣
║ [R]efresh | [L]ogs | [S]top | [Q]uit                        ║
╚══════════════════════════════════════════════════════════════╝
```

### 5. Notification System

#### macOS Notification
```bash
# タスク完了通知
osascript -e 'display notification "Codex task completed: 19 PRs reviewed" with title "Miyabi Codex Monitor"'

# サウンド通知
afplay /System/Library/Sounds/Glass.aiff
```

#### Slack/Discord Webhook
```bash
curl -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Codex PR Review Completed",
    "attachments": [{
      "color": "good",
      "fields": [
        {"title": "Total PRs", "value": "19", "short": true},
        {"title": "Approved", "value": "15", "short": true},
        {"title": "Changes Requested", "value": "3", "short": true},
        {"title": "Commented", "value": "1", "short": true}
      ]
    }]
  }'
```

### 6. Health Check & Auto-Recovery

```bash
# ヘルスチェック（5分間隔）
*/5 * * * * /Users/shunsuke/Dev/miyabi-private/scripts/codex-health-check.sh

# 停止検出時の自動再起動
if [[ $(check_task_status) == "stalled" ]]; then
  restart_task "$TASK_ID"
fi
```

### 7. Result Aggregation

```bash
# 全タスク結果の集計
./scripts/codex-aggregate-results.sh \
  --tasks "codex-pr-review-2025-10-31,codex-branch-cleanup-2025-10-31" \
  --output ".ai/reports/codex-summary-2025-10-31.md"
```

## Implementation Files

### Required Scripts
1. **scripts/codex-task-runner.sh** - タスク実行・管理
2. **scripts/codex-monitor-tui.sh** - TUIダッシュボード
3. **scripts/codex-health-check.sh** - ヘルスチェック
4. **scripts/codex-aggregate-results.sh** - 結果集計

### Integration with Miyabi

```rust
// crates/miyabi-codex-monitor/src/lib.rs
pub struct CodexTaskMonitor {
    task_id: String,
    status_path: PathBuf,
    log_path: PathBuf,
}

impl CodexTaskMonitor {
    pub fn new(task_id: &str) -> Self { /* ... */ }
    pub fn get_status(&self) -> Result<TaskStatus> { /* ... */ }
    pub fn get_progress(&self) -> Result<Progress> { /* ... */ }
    pub fn tail_logs(&self, n: usize) -> Result<Vec<String>> { /* ... */ }
    pub fn wait_for_completion(&self) -> Result<TaskResults> { /* ... */ }
}
```

## Usage Example

```bash
# 1. タスク開始
TASK_ID=$(./scripts/codex-task-runner.sh start \
  --task-id "codex-pr-review-$(date +%Y-%m-%d)" \
  --instructions "/tmp/codex_pr_review_instructions.md" \
  --type "pr_review")

# 2. モニタリング開始（別ターミナル）
./scripts/codex-monitor-tui.sh "$TASK_ID"

# 3. 結果待機（ブロッキング）
./scripts/codex-task-runner.sh wait "$TASK_ID"

# 4. 結果取得
./scripts/codex-task-runner.sh results "$TASK_ID" > codex-results.json

# 5. レポート生成
./scripts/codex-task-runner.sh report "$TASK_ID" --format markdown > CODEX_REPORT.md
```

## Next Steps

1. スクリプト実装
2. TUIダッシュボード開発（Rust + ratatui）
3. Webhook統合
4. 自動リカバリー機能
5. Miyabi CLI統合 (`miyabi codex monitor <task-id>`)
