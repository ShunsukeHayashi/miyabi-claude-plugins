---
name: mcp-integration
description: MCP server integration and tool usage. Use when working with MCP tools, searching for tools, or configuring MCP servers. Triggers: mcp, tools, miyabi-mcp-bundle, 172 tools
---

# MCP Integration

## Available MCP Servers

### Core (Always Enabled)
| Server | Command | Tools |
|--------|---------|-------|
| `filesystem` | npx @modelcontextprotocol/server-filesystem | ファイル操作 |
| `miyabi-mcp-bundle` | npx miyabi-mcp-bundle | 172+ tools |

### Optional (Disabled by Default)
| Server | Description | Required Setup |
|--------|-------------|----------------|
| `github-enhanced` | 拡張GitHub操作 | ローカルセットアップ |
| `gemini-image-generation` | 画像生成 | GOOGLE_API_KEY |
| `discord-community` | Discord連携 | Discord Bot設定 |
| `miyabi-tmux` | tmux通信 | ローカルtmux |

## Tool Categories (miyabi-mcp-bundle)

| Category | Tools | Description |
|----------|-------|-------------|
| git | 19 | バージョン管理 |
| github | 21 | Issue/PR/Actions |
| docker | 10 | コンテナ管理 |
| k8s | 6 | Kubernetes |
| network | 15 | ネットワーク診断 |
| process | 14 | プロセス管理 |
| tmux | 10 | セッション管理 |
| resource | 10 | システム監視 |
| file | 10 | ファイル操作 |
| log | 7 | ログ解析 |

## Progressive Disclosure Pattern

大量のツールを一度に読み込まない:

```typescript
// Step 1: カテゴリ一覧
mcp_list_categories()

// Step 2: カテゴリ内検索
mcp_search_tools({ category: "github" })

// Step 3: ツール詳細
mcp_get_tool_info({ tool: "github_create_pr" })
```

## Tool Naming Convention

`category_action` 形式:
- `git_status`, `git_diff`
- `github_list_issues`, `github_create_pr`
- `docker_logs`, `docker_ps`

## Environment Variables

```bash
# Required
GITHUB_TOKEN=xxx
GITHUB_DEFAULT_OWNER=xxx
GITHUB_DEFAULT_REPO=xxx

# Optional
GOOGLE_API_KEY=xxx
DISCORD_BOT_TOKEN=xxx
```
