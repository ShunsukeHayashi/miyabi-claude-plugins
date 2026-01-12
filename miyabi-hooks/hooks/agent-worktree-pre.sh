#!/bin/bash
# Agent Worktree Pre-Hook - Create worktree before Sub-Agent execution
# Version: 1.0.0
# Usage: Called by PreToolUse(Task) hook
# Input: JSON via stdin containing tool_input from Task tool

set -euo pipefail

# Source worktree manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/worktree-manager.sh"

# Color codes
readonly PRE_CYAN='\033[0;36m'
readonly PRE_GREEN='\033[0;32m'
readonly PRE_YELLOW='\033[1;33m'
readonly PRE_RED='\033[0;31m'
readonly PRE_NC='\033[0m'

# Parse JSON input from stdin
parse_task_input() {
    local input
    input=$(cat)

    # Extract fields using jq
    SUBAGENT_TYPE=$(echo "$input" | jq -r '.subagent_type // .type // "unknown"')
    TASK_DESC=$(echo "$input" | jq -r '.description // .prompt // "task"')
    ISSUE_NUMBER=$(echo "$input" | jq -r '.issue_number // .issue // ""')
    PROMPT=$(echo "$input" | jq -r '.prompt // ""')

    log INFO "Parsed Task input: subagent=$SUBAGENT_TYPE, issue=$ISSUE_NUMBER, desc=$TASK_DESC"
}

# Main execution
main() {
    log INFO "PreToolUse(Task) hook triggered - Creating worktree for Sub-Agent"

    # Check if main session is already in a worktree (ERROR - Orchestrator should stay in main)
    if is_in_worktree; then
        log ERROR "Main session is already in a worktree! Orchestrator should stay in main branch."
        log ERROR "Current worktree: $(get_current_worktree_name)"
        echo -e "${PRE_RED}ERROR: Orchestrator cannot be in worktree. Please cleanup first.${PRE_NC}" >&2
        exit 1
    fi

    # Parse input
    parse_task_input

    # Validate subagent_type
    if [[ "$SUBAGENT_TYPE" == "unknown" ]] || [[ -z "$SUBAGENT_TYPE" ]]; then
        log WARN "No subagent_type specified in Task tool input. Skipping worktree creation."
        exit 0
    fi

    # Call worktree-manager.sh to create worktree
    log INFO "Creating worktree for Sub-Agent: $SUBAGENT_TYPE"

    if [[ -n "$ISSUE_NUMBER" ]]; then
        create_subagent_worktree "$SUBAGENT_TYPE" "$TASK_DESC" "$ISSUE_NUMBER" "$PROMPT"
    else
        create_subagent_worktree "$SUBAGENT_TYPE" "$TASK_DESC" "" "$PROMPT"
    fi

    local worktree_path=$(get_last_created_worktree_path)

    if [[ -n "$worktree_path" ]]; then
        log SUCCESS "Worktree created successfully: $worktree_path"
        echo -e "${PRE_GREEN}Worktree ready for Sub-Agent: $worktree_path${PRE_NC}" >&2

        # VOICEVOX notification (macOS only)
        if [[ "$OSTYPE" == "darwin"* ]] && command -v osascript &>/dev/null; then
            osascript -e "display notification \"Creating worktree for $SUBAGENT_TYPE\" with title \"Miyabi Orchestrator\" sound name \"Glass\"" 2>/dev/null || true
        fi
    else
        log ERROR "Failed to create worktree for Sub-Agent: $SUBAGENT_TYPE"
        exit 1
    fi

    return 0
}

# Run main
main
