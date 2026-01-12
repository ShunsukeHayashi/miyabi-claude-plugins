# /task-decompose - タスク分解コマンド

## 使い方

```bash
/task-decompose 884
/task-decompose #885
```

## 機能

1. CoordinatorAgentでIssueを分析
2. サブタスクに分解してDAG生成
3. SQLiteに依存関係を保存
4. GitHub Issueにコメント投稿

## 実装

```bash
bash ~/miyabi-private/scripts/task-decompose-bg.sh "$@"
```
