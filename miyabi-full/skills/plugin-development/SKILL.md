---
name: plugin-development
description: Claude Code plugin development guide. Use when creating commands, skills, hooks, or agents for plugins. Triggers: plugin, command, skill, hook, agent development
---

# Plugin Development

## Plugin Structure

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json          # Required: metadata
├── commands/                # Slash commands
│   └── hello.md
├── agents/                  # Subagents
│   └── reviewer.md
├── skills/                  # Agent skills
│   └── code-review/
│       └── SKILL.md
├── hooks/                   # Event handlers
│   └── hooks.json
└── .mcp.json               # MCP server config
```

## Creating Commands

File: `commands/my-command.md`

```markdown
---
description: Short description for help
---

# Command Name

Instructions for Claude to execute this command.
Use $ARGUMENTS for user input.
Use $1, $2 for positional parameters.
```

Command naming: `/plugin-name:command-name`

## Creating Skills

Directory: `skills/my-skill/SKILL.md`

```yaml
---
name: my-skill
description: Description with triggers. Triggers: keyword1, keyword2
---

# My Skill

Instructions and workflows...
```

## Creating Hooks

File: `hooks/hooks.json`

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/script.sh"
          }
        ]
      }
    ]
  }
}
```

### Supported Events
- `PreToolUse` - Before tool execution
- `PostToolUse` - After successful execution
- `PostToolUseFailure` - After failed execution
- `SessionStart` - Session begins
- `SessionEnd` - Session ends
- `UserPromptSubmit` - User sends prompt

## Creating Agents

File: `agents/my-agent.md`

```markdown
---
description: Agent specialization
capabilities: ["code-review", "testing"]
---

# Agent Name

Detailed role description...
```

## Environment Variables

- `${CLAUDE_PLUGIN_ROOT}` - Plugin root directory
- `$TOOL_NAME` - Current tool name
- `$TOOL_INPUT` - Tool input
- `$TOOL_OUTPUT` - Tool output
