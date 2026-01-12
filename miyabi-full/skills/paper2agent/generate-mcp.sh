#!/bin/bash
# generate-mcp.sh - Generate MCP server definition from paper and code analysis
# Version: 1.0.0
# Part of: Paper2Agent Skill

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${MIYABI_PAPER2AGENT_CACHE_DIR:-$HOME/.miyabi/paper2agent}"
MCP_OUTPUT_DIR="${MIYABI_MCP_SERVERS_DIR:-.claude/mcp-servers/paper2agent}"

mkdir -p "$MCP_OUTPUT_DIR"

# ============================================================
# Functions
# ============================================================

log() {
  echo "[$(date -Iseconds)] $*" >&2
}

load_paper_analysis() {
  local analysis_file="$1"

  if [ ! -f "$analysis_file" ]; then
    log "ERROR: Paper analysis file not found: $analysis_file"
    exit 1
  fi

  log "Loading paper analysis from $analysis_file"
  cat "$analysis_file"
}

load_code_analysis() {
  local analysis_file="$1"

  if [ ! -f "$analysis_file" ]; then
    log "ERROR: Code analysis file not found: $analysis_file"
    exit 1
  fi

  log "Loading code analysis from $analysis_file"
  cat "$analysis_file"
}

generate_mcp_name() {
  local paper_title="$1"

  # Convert title to kebab-case
  echo "$paper_title" | \
    tr '[:upper:]' '[:lower:]' | \
    sed 's/[^a-z0-9]/-/g' | \
    sed 's/--*/-/g' | \
    sed 's/^-//' | \
    sed 's/-$//' | \
    cut -c1-50
}

generate_tool_schema() {
  local func_name="$1"
  local func_sig="$2"
  local language="$3"

  # Extract parameters from signature (simple parsing)
  local params=$(echo "$func_sig" | grep -o '([^)]*)' | tr -d '()')

  cat <<EOF
    {
      "name": "$func_name",
      "description": "Execute $func_name from paper implementation",
      "inputSchema": {
        "type": "object",
        "properties": {
          "input": {
            "type": "string",
            "description": "Input data for $func_name"
          }
        },
        "required": ["input"]
      }
    }
EOF
}

generate_mcp_server_json() {
  local paper_analysis="$1"
  local code_analysis="$2"
  local output_file="$3"

  log "Generating MCP server definition"

  # Extract metadata
  local paper_title=$(echo "$paper_analysis" | jq -r '.title // "Unknown Paper"')
  local arxiv_id=$(echo "$paper_analysis" | jq -r '.arxiv_id // ""')
  local language=$(echo "$code_analysis" | jq -r '.language // "python"')

  # Generate MCP name
  local mcp_name=$(generate_mcp_name "$paper_title")
  log "MCP server name: paper-$mcp_name"

  # Extract functions from code analysis
  local functions=$(echo "$code_analysis" | jq -c '.sample_functions[]? // empty' 2>/dev/null || echo "")

  # Start JSON output
  cat > "$output_file" <<EOF
{
  "name": "paper-$mcp_name",
  "version": "1.0.0",
  "description": "MCP server generated from: $paper_title",
  "metadata": {
    "arxiv_id": "$arxiv_id",
    "language": "$language",
    "generated_at": "$(date -Iseconds)",
    "generator": "miyabi-paper2agent"
  },
  "command": "python",
  "args": ["-m", "paper_${mcp_name//-/_}.mcp_server"],
  "tools": [
EOF

  # Add tools for each function
  local first=true
  if [ -n "$functions" ]; then
    echo "$functions" | while IFS= read -r func; do
      local func_name=$(echo "$func" | jq -r '.name // .signature' | cut -d'(' -f1 | xargs)
      local func_sig=$(echo "$func" | jq -r '.signature // .name')

      if [ "$first" = true ]; then
        first=false
      else
        echo "," >> "$output_file"
      fi

      generate_tool_schema "$func_name" "$func_sig" "$language" >> "$output_file"
    done
  else
    # No functions found - generate generic tool
    cat >> "$output_file" <<TOOLEOF
    {
      "name": "execute",
      "description": "Execute paper implementation",
      "inputSchema": {
        "type": "object",
        "properties": {
          "query": {
            "type": "string",
            "description": "Input query"
          }
        },
        "required": ["query"]
      }
    }
TOOLEOF
  fi

  # Close JSON
  cat >> "$output_file" <<EOF

  ]
}
EOF

  log "MCP server definition saved to $output_file"
}

generate_mcp_server_python() {
  local mcp_name="$1"
  local code_analysis="$2"
  local output_dir="$3"

  log "Generating Python MCP server implementation"

  local server_name="paper_${mcp_name//-/_}"
  local server_dir="$output_dir/$server_name"
  mkdir -p "$server_dir"

  # Generate mcp_server.py
  cat > "$server_dir/mcp_server.py" <<'EOF'
#!/usr/bin/env python3
"""
MCP Server for Paper2Agent
Auto-generated from paper analysis

This server exposes paper implementation as MCP tools.
"""

import asyncio
import json
import sys
from typing import Any, Dict

class PaperMCPServer:
    """MCP Server wrapper for paper implementation"""

    def __init__(self):
        self.name = "paper-implementation"

    async def call_tool(self, name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute a tool call.

        Args:
            name: Tool name
            arguments: Tool arguments

        Returns:
            Tool execution result
        """
        # TODO: Implement actual paper code integration
        return {
            "success": True,
            "result": f"Executed {name} with args: {arguments}",
            "message": "Implementation pending - integrate actual paper code here"
        }

    async def list_tools(self) -> list:
        """List available tools"""
        # TODO: Load from MCP definition JSON
        return [
            {
                "name": "execute",
                "description": "Execute paper implementation",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "query": {"type": "string"}
                    }
                }
            }
        ]

async def main():
    """Main server loop"""
    server = PaperMCPServer()

    # Read stdin for MCP protocol messages
    async for line in sys.stdin:
        try:
            request = json.loads(line)
            method = request.get("method")

            if method == "tools/list":
                tools = await server.list_tools()
                response = {"tools": tools}
            elif method == "tools/call":
                name = request.get("params", {}).get("name")
                arguments = request.get("params", {}).get("arguments", {})
                result = await server.call_tool(name, arguments)
                response = {"result": result}
            else:
                response = {"error": f"Unknown method: {method}"}

            print(json.dumps(response), flush=True)

        except Exception as e:
            error_response = {"error": str(e)}
            print(json.dumps(error_response), flush=True)

if __name__ == "__main__":
    asyncio.run(main())
EOF

  chmod +x "$server_dir/mcp_server.py"

  # Generate requirements.txt
  cat > "$server_dir/requirements.txt" <<EOF
# MCP Server dependencies
# Add paper-specific dependencies here
EOF

  # Generate README
  cat > "$server_dir/README.md" <<EOF
# Paper2Agent MCP Server: $server_name

Auto-generated MCP server from paper analysis.

## Installation

\`\`\`bash
pip install -r requirements.txt
\`\`\`

## Usage

\`\`\`bash
# Test server
python mcp_server.py

# Register in Miyabi
miyabi mcp register paper-$mcp_name
\`\`\`

## TODO

1. Integrate actual paper code
2. Add proper error handling
3. Implement paper-specific tools
4. Add validation tests
EOF

  log "Python MCP server generated at $server_dir"
}

# ============================================================
# Main Logic
# ============================================================

usage() {
  cat <<EOF
Usage: $0 --paper-analysis <file> --code-analysis <file> [options]

Generate MCP server definition from paper and code analysis.

Options:
  --paper-analysis <file>   Paper analysis JSON (required)
  --code-analysis <file>    Code analysis JSON (required)
  --output <file>           Output MCP JSON file (default: auto-generated)
  --generate-impl           Generate Python implementation skeleton

Environment:
  MIYABI_PAPER2AGENT_CACHE_DIR   Cache directory (default: ~/.miyabi/paper2agent)
  MIYABI_MCP_SERVERS_DIR         MCP servers directory (default: .claude/mcp-servers/paper2agent)

Examples:
  # Generate MCP definition
  $0 --paper-analysis paper.json --code-analysis code.json

  # Generate with implementation
  $0 --paper-analysis paper.json --code-analysis code.json --generate-impl
EOF
  exit 1
}

main() {
  local paper_analysis_file=""
  local code_analysis_file=""
  local output_file=""
  local generate_impl=false

  # Parse arguments
  while [ $# -gt 0 ]; do
    case "$1" in
      --paper-analysis)
        paper_analysis_file="$2"
        shift 2
        ;;
      --code-analysis)
        code_analysis_file="$2"
        shift 2
        ;;
      --output)
        output_file="$2"
        shift 2
        ;;
      --generate-impl)
        generate_impl=true
        shift
        ;;
      *)
        usage
        ;;
    esac
  done

  if [ -z "$paper_analysis_file" ] || [ -z "$code_analysis_file" ]; then
    log "ERROR: Both --paper-analysis and --code-analysis are required"
    usage
  fi

  # Load analyses
  local paper_analysis=$(load_paper_analysis "$paper_analysis_file")
  local code_analysis=$(load_code_analysis "$code_analysis_file")

  # Generate MCP name
  local paper_title=$(echo "$paper_analysis" | jq -r '.title // "Unknown Paper"')
  local mcp_name=$(generate_mcp_name "$paper_title")

  # Set output file if not specified
  if [ -z "$output_file" ]; then
    output_file="$MCP_OUTPUT_DIR/paper-$mcp_name.json"
  fi

  mkdir -p "$(dirname "$output_file")"

  # Generate MCP server JSON
  generate_mcp_server_json "$paper_analysis" "$code_analysis" "$output_file"

  # Generate implementation if requested
  if [ "$generate_impl" = true ]; then
    generate_mcp_server_python "$mcp_name" "$code_analysis" "$MCP_OUTPUT_DIR"
  fi

  log "✅ MCP generation complete"
  log "Definition: $output_file"

  if [ "$generate_impl" = true ]; then
    log "Implementation: $MCP_OUTPUT_DIR/paper_${mcp_name//-/_}/"
  fi

  # Output final path
  echo "$output_file"
}

# ============================================================
# Entry Point
# ============================================================

if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
