# Miyabi Plugins for Claude Code

Complete autonomous AI development operations platform - Transform Claude Code into a powerful development assistant with 25+ AI agents, 22 skills, and 50+ commands.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Guide](#installation-guide)
- [Verify Installation](#verify-installation)
- [First Steps](#first-steps)
- [Available Plugins](#available-plugins)
- [Core Features](#core-features)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

---

## Prerequisites

Before installing Miyabi plugins, ensure you have:

### Required

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| **Claude Code CLI** | Latest | `claude --version` |
| **Node.js** | 18.0+ | `node --version` |
| **npm** | 9.0+ | `npm --version` |

### Optional (for full features)

| Requirement | Purpose | Setup |
|-------------|---------|-------|
| **GitHub Token** | GitHub integration (issues, PRs) | [Create token](https://github.com/settings/tokens) |
| **tmux** | Multi-agent orchestration | `brew install tmux` (macOS) |

### Install Claude Code CLI

If you don't have Claude Code CLI installed:

```bash
# Install via npm
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version
```

---

## Installation Guide

### Step 1: Add Marketplace

Open Claude Code and run the following command:

```bash
/plugin marketplace add ShunsukeHayashi/miyabi-claude-plugins
```

**Expected output:**
```
✓ Marketplace 'miyabi-plugins' added successfully
  Source: https://github.com/ShunsukeHayashi/miyabi-claude-plugins
  Plugins available: 8
```

### Step 2: Install Plugin

Choose ONE of the following options:

#### Option A: Full Package (Recommended)

```bash
/plugin install miyabi-full@miyabi-plugins
```

This includes everything: 38 agents, 56 commands, 25 skills, hooks, and MCP integration.

#### Option B: Individual Packages

Install only what you need:

```bash
# Coding automation
/plugin install miyabi-coding-agents@miyabi-plugins

# Business automation
/plugin install miyabi-business-agents@miyabi-plugins

# Commands only
/plugin install miyabi-commands@miyabi-plugins

# Skills only
/plugin install miyabi-skills@miyabi-plugins
```

### Step 3: Restart Claude Code

After installation, restart Claude Code to load the plugins:

```bash
# Exit current session
/exit

# Start new session
claude
```

---

## Verify Installation

### Check Installed Plugins

```bash
/plugin list
```

**Expected output:**
```
Installed plugins:
  ✓ miyabi-full (v2.1.0) - Miyabi 完全パッケージ
    Source: miyabi-plugins
    Agents: 38 | Commands: 56 | Skills: 25
```

### Test MCP Connection

```bash
/miyabi-full:health-check
```

**Expected output:**
```
✓ MCP Server: miyabi-mcp-bundle connected
✓ Tools available: 172
✓ All systems operational
```

### Test a Command

```bash
/miyabi-full:dashboard
```

This should display your project dashboard.

---

## First Steps

### Tutorial 1: Your First Agent

Ask Claude to use the CodeGen agent:

```
Use the CodeGen agent to create a simple React component for a user profile card.
```

### Tutorial 2: Run a Command

Create an issue on GitHub:

```bash
/miyabi-full:issue-create --title "Test issue" --body "Testing Miyabi integration"
```

### Tutorial 3: Use a Skill

Trigger the git-workflow skill:

```
Help me with git workflow - I need to create a feature branch and commit my changes.
```

### Tutorial 4: Agent Orchestration (Advanced)

For multi-agent workflows:

```
Use the Coordinator agent to:
1. Analyze the current codebase
2. Generate code improvements with CodeGen
3. Review the changes with ReviewAgent
4. Create a PR with PRAgent
```

---

## Available Plugins

| Plugin | Description | Contents |
|--------|-------------|----------|
| **miyabi-full** | Complete package (recommended) | All agents, skills, commands, hooks |
| **miyabi-coding-agents** | Development automation | 9 coding agents |
| **miyabi-business-agents** | Business automation | 16 business agents |
| **miyabi-commands** | Slash commands | 50+ commands |
| **miyabi-skills** | Development skills | 22 skills |
| **miyabi-hooks** | Automation hooks | Pre/Post tool hooks |
| **miyabi-guardian** | Incident response | Guardian agent |
| **miyabi-honoka** | Course creation | Udemy specialist |

---

## Core Features

### Coding Agents (9)

| Agent | Purpose | Trigger |
|-------|---------|---------|
| **CoordinatorAgent** | Task orchestration & delegation | "coordinate", "orchestrate" |
| **CodeGenAgent** | Code generation | "generate code", "implement" |
| **ReviewAgent** | Code review & quality | "review", "check code" |
| **PRAgent** | Pull request management | "create PR", "merge" |
| **DeploymentAgent** | Deployment automation | "deploy", "release" |
| **IssueAgent** | GitHub issue management | "create issue", "track" |
| **RefresherAgent** | Context refresh | "refresh context" |
| **BatchIssueAgent** | Batch operations | "batch process" |
| **AWSAgent** | AWS operations | "AWS", "cloud" |

### Business Agents (16)

| Agent | Purpose |
|-------|---------|
| **MarketingAgent** | Marketing strategy & campaigns |
| **SalesAgent** | Sales automation & outreach |
| **CRMAgent** | Customer relationship management |
| **YouTubeAgent** | YouTube content strategy |
| **AnalyticsAgent** | Data analysis & reporting |
| **ContentCreationAgent** | Content generation |
| **FunnelDesignAgent** | Sales funnel design |
| **PersonaAgent** | Customer persona creation |
| **SNSStrategyAgent** | Social media strategy |
| And 7 more... | |

### Commands (50+)

```bash
# Development
/miyabi-full:deploy          # Deploy application
/miyabi-full:pr-create       # Create pull request
/miyabi-full:issue-create    # Create issue
/miyabi-full:health-check    # System health check
/miyabi-full:review          # Code review

# Git Operations
/miyabi-full:worktree-create # Create git worktree
/miyabi-full:worktree-list   # List worktrees

# Automation
/miyabi-full:agent-run       # Run specific agent
/miyabi-full:codex           # Codex integration
/miyabi-full:tmux-control    # tmux session control
/miyabi-full:parallel-execute # Parallel task execution

# Monitoring
/miyabi-full:dashboard       # Project dashboard
/miyabi-full:logs            # View logs
/miyabi-full:quality-score   # Code quality metrics
```

### Skills (22)

| Category | Skills |
|----------|--------|
| **Development** | rust-development, tdd-workflow, git-workflow |
| **Quality** | security-audit, performance-analysis, debugging-troubleshooting |
| **Documentation** | documentation-generation, context-eng |
| **Business** | business-strategy-planning, market-research-analysis |
| **Integration** | mcp-integration, tmux-iterm-integration |

---

## Configuration

### Environment Variables

Create or update your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
# Required for GitHub integration
export GITHUB_TOKEN="your_github_personal_access_token"
export GITHUB_DEFAULT_OWNER="your_github_username_or_org"
export GITHUB_DEFAULT_REPO="your_default_repo"

# Optional for advanced features
export GOOGLE_API_KEY="your_google_api_key"        # Image generation
export DISCORD_BOT_TOKEN="your_discord_bot_token"  # Discord integration
```

Apply changes:

```bash
source ~/.zshrc  # or source ~/.bashrc
```

### GitHub Token Permissions

When creating your GitHub token, enable these scopes:

- `repo` - Full control of private repositories
- `workflow` - Update GitHub Action workflows
- `read:org` - Read organization membership

### MCP Servers

The `miyabi-full` plugin automatically configures these MCP servers:

| Server | Description | Status |
|--------|-------------|--------|
| `miyabi-mcp-bundle` | 172+ tools (Git, GitHub, Docker, K8s, etc.) | Enabled |
| `filesystem` | File system access | Enabled |

---

## Troubleshooting

### Plugin Not Found

**Symptom:** `/plugin install miyabi-full@miyabi-plugins` returns "plugin not found"

**Solution:**
```bash
# Re-add marketplace
/plugin marketplace remove miyabi-plugins
/plugin marketplace add ShunsukeHayashi/miyabi-claude-plugins

# Try install again
/plugin install miyabi-full@miyabi-plugins
```

### MCP Connection Failed

**Symptom:** "MCP server miyabi-mcp-bundle not connected"

**Solution:**
```bash
# Ensure Node.js is installed
node --version

# Test MCP server manually
npx miyabi-mcp-bundle

# If error, install globally
npm install -g miyabi-mcp-bundle
```

### Commands Not Working

**Symptom:** `/miyabi-full:deploy` returns "command not found"

**Solution:**
```bash
# Check plugin is installed
/plugin list

# Reinstall plugin
/plugin uninstall miyabi-full@miyabi-plugins
/plugin install miyabi-full@miyabi-plugins

# Restart Claude Code
/exit
claude
```

### GitHub Integration Not Working

**Symptom:** GitHub commands fail with authentication errors

**Solution:**
```bash
# Check token is set
echo $GITHUB_TOKEN

# Test token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# If error, regenerate token at:
# https://github.com/settings/tokens
```

### Permission Denied on Scripts

**Symptom:** Hook scripts fail with permission denied

**Solution:**
```bash
# Find plugin directory
/plugin info miyabi-full

# Make scripts executable (adjust path as needed)
chmod +x ~/.claude/plugins/miyabi-full/scripts/*.sh
chmod +x ~/.claude/plugins/miyabi-full/hooks/*.sh
```

---

## Updating Plugins

### Check for Updates

```bash
/plugin outdated
```

### Update Plugin

```bash
/plugin update miyabi-full@miyabi-plugins
```

### Update All Plugins

```bash
/plugin update --all
```

---

## Uninstallation

### Remove Plugin

```bash
/plugin uninstall miyabi-full@miyabi-plugins
```

### Remove Marketplace

```bash
/plugin marketplace remove miyabi-plugins
```

---

## Directory Structure

```
miyabi-claude-plugins/
├── marketplace.json         # Marketplace definition
├── README.md                # This file
├── miyabi-full/             # Complete package
│   ├── .claude-plugin/
│   │   └── plugin.json      # Plugin metadata
│   ├── agents/              # 38 agent definitions
│   ├── commands/            # 56 slash commands
│   ├── skills/              # 25 skill definitions
│   ├── hooks/               # Automation hooks
│   │   └── hooks.json       # Hook configuration
│   ├── scripts/             # Helper scripts
│   └── .mcp.json            # MCP server config
├── miyabi-coding-agents/    # Coding agents only
├── miyabi-business-agents/  # Business agents only
├── miyabi-commands/         # Commands only
├── miyabi-skills/           # Skills only
├── miyabi-hooks/            # Hooks only
├── miyabi-guardian/         # Incident response
└── miyabi-honoka/           # Course creation
```

---

## Support

| Channel | Link |
|---------|------|
| **GitHub Issues** | [Report a bug](https://github.com/ShunsukeHayashi/miyabi-claude-plugins/issues) |
| **Discord** | [Miyabi Community](https://discord.gg/miyabi) |
| **Documentation** | [Miyabi Docs](https://miyabi-world.com/docs) |

---

## License

Apache-2.0

---

## Author

**Shunsuke Hayashi** ([@ShunsukeHayashi](https://github.com/ShunsukeHayashi))

---

## Related Projects

| Project | Description | Link |
|---------|-------------|------|
| **miyabi-mcp-bundle** | MCP server with 172+ tools | [npm](https://www.npmjs.com/package/miyabi-mcp-bundle) |
| **Claude Code** | Anthropic's CLI for Claude | [Anthropic](https://claude.ai/code) |
