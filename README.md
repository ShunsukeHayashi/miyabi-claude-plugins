# Miyabi Plugins for Claude Code

Complete autonomous AI development operations platform - Transform Claude Code into a powerful development assistant with 25+ AI agents, 22 skills, and 50+ commands.

## Quick Install

```bash
# Add marketplace
/plugin marketplace add ShunsukeHayashi/miyabi-claude-plugins

# Install full package (recommended)
/plugin install miyabi-full@miyabi-plugins

# Or install individual packages
/plugin install miyabi-coding-agents@miyabi-plugins
/plugin install miyabi-business-agents@miyabi-plugins
/plugin install miyabi-skills@miyabi-plugins
/plugin install miyabi-commands@miyabi-plugins
```

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

## Core Agents

### Coding Agents (9)
- **CoordinatorAgent** - Task orchestration
- **CodeGenAgent** - Code generation
- **ReviewAgent** - Code review
- **PRAgent** - Pull request management
- **DeploymentAgent** - Deployment automation
- **IssueAgent** - Issue management
- **RefresherAgent** - Context refresh
- **BatchIssueAgent** - Batch operations
- **AWSAgent** - AWS operations

### Business Agents (16)
- MarketingAgent, SalesAgent, CRMAgent
- YouTubeAgent, AnalyticsAgent, ContentCreationAgent
- And 10 more...

## Commands Reference

```bash
# Development
/miyabi-full:deploy          # Deploy application
/miyabi-full:pr-create       # Create pull request
/miyabi-full:issue-create    # Create issue
/miyabi-full:health-check    # System health check

# Automation
/miyabi-full:agent-run       # Run agent
/miyabi-full:codex           # Codex integration
/miyabi-full:tmux-control    # tmux session control
```

## Skills

- **rust-development** - Rust best practices
- **tdd-workflow** - Test-driven development
- **git-workflow** - Git operations
- **security-audit** - Security analysis
- **performance-analysis** - Performance optimization
- And 17 more...

## Configuration

### Environment Variables

```bash
# Required for GitHub integration
GITHUB_TOKEN=your_github_token
GITHUB_DEFAULT_OWNER=your_org
GITHUB_DEFAULT_REPO=your_repo

# Optional for advanced features
GOOGLE_API_KEY=your_google_key
DISCORD_BOT_TOKEN=your_discord_token
```

### MCP Servers

The `miyabi-full` plugin includes pre-configured MCP servers:
- `miyabi-mcp-bundle` - 172+ tools (Git, GitHub, Docker, K8s, etc.)
- `filesystem` - File system access
- Additional servers (disabled by default)

## Local Development

```bash
# Test plugin locally
claude --plugin-dir ./miyabi-full

# Test multiple plugins
claude --plugin-dir ./miyabi-coding-agents --plugin-dir ./miyabi-skills
```

## Directory Structure

```
claude-plugins/
├── .claude-plugin/
│   └── marketplace.json     # Marketplace definition
├── miyabi-full/             # Complete package
│   ├── .claude-plugin/
│   │   └── plugin.json
│   ├── agents/              # 38 agents
│   ├── commands/            # 56 commands
│   ├── skills/              # 22 skills
│   ├── hooks/               # Automation hooks
│   ├── scripts/             # Helper scripts
│   └── .mcp.json            # MCP server config
├── miyabi-coding-agents/    # Coding focus
├── miyabi-business-agents/  # Business focus
├── miyabi-commands/         # Commands only
├── miyabi-skills/           # Skills only
├── miyabi-hooks/            # Hooks only
├── miyabi-guardian/         # Incident response
└── miyabi-honoka/           # Course creation
```

## Support

- **Discord**: [Miyabi Community](https://discord.gg/miyabi)
- **GitHub**: [Issues](https://github.com/ShunsukeHayashi/miyabi-claude-plugins/issues)
- **Documentation**: [Miyabi Docs](https://miyabi-world.com/docs)

## License

Apache-2.0

---

**Author**: Shunsuke Hayashi ([@ShunsukeHayashi](https://github.com/ShunsukeHayashi))
