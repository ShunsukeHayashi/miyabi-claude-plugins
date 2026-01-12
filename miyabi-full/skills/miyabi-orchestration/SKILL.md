---
name: miyabi-orchestration
description: Miyabi Agent Society orchestration and communication. Use when working with multiple agents, task distribution, or agent communication. Triggers: agents, orchestration, しきるん, カエデ, サクラ, ツバキ, ボタン, tmux
---

# Miyabi Agent Orchestration

## Available Agents

| Agent | Role | tmux Target |
|-------|------|-------------|
| しきるん 🎭 | Conductor - タスク分配・進捗管理 | `miyabi:agents.0` |
| カエデ 🍁 | CodeGen - コード生成・実装 | `miyabi:agents.1` |
| サクラ 🌸 | Review - コードレビュー・品質保証 | `miyabi:agents.2` |
| ツバキ 🌺 | PR - プルリクエスト管理・GitHub連携 | `miyabi:agents.3` |
| ボタン 🌼 | Deploy - デプロイ・リリース管理 | `miyabi:agents.4` |
| ながれるん 🌊 | n8n - ワークフロー自動化 | `miyabi:agents.5` |

## Agent Communication

```bash
# tmux経由でエージェント間通信
tmux send-keys -t miyabi:agents.0 "message" Enter

# スクリプト経由（推奨）
${CLAUDE_PLUGIN_ROOT}/scripts/a2a-send.sh conductor "message"
```

## Task Distribution Flow

```
1. しきるん: タスク受領・分解
2. カエデ: コード生成
3. サクラ: コードレビュー
4. ツバキ: PR作成
5. ボタン: デプロイ
6. しきるん: 完了確認
```

## Invoking Agents

Use Task tool with subagent_type:

```
Task tool: subagent_type="shikirun" → しきるん
Task tool: subagent_type="kaede" → カエデ
Task tool: subagent_type="sakura" → サクラ
Task tool: subagent_type="tsubaki" → ツバキ
Task tool: subagent_type="botan" → ボタン
Task tool: subagent_type="nagarerrun" → ながれるん
```

## Error Handling

- エージェント応答なし → 3回リトライ
- タスク失敗 → しきるんに報告
- 緊急停止 → emergency-stop.sh 実行
