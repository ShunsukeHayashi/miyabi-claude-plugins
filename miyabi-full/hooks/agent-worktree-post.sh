#!/bin/bash
# Agent Worktree Post-Hook - Cleanup worktree after Sub-Agent execution
# Version: 1.0.0
# Usage: Called by PostToolUse(Task) hook
# Input: JSON via stdin containing tool_input from Task tool

set -euo pipefail

# Source worktree manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/worktree-manager.sh"

# Color codes
readonly POST_CYAN='\033[0;36m'
readonly POST_GREEN='\033[0;32m'
readonly POST_YELLOW='\033[1;33m'
readonly POST_RED='\033[0;31m'
readonly POST_NC='\033[0m'

# Parse JSON input from stdin
parse_task_result() {
    local input
    input=$(cat)

    # Extract fields using jq
    SUBAGENT_TYPE=$(echo "$input" | jq -r '.subagent_type // .type // "unknown"')
    SUCCESS=$(echo "$input" | jq -r '.success // true')
    RESULT=$(echo "$input" | jq -r '.result // ""')

    log INFO "Parsed Task result: subagent=$SUBAGENT_TYPE, success=$SUCCESS"
}

# Check if Sub-Agent execution was successful
check_execution_success() {
    # Check git status for uncommitted changes (indicates work was done)
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log INFO "Changes detected in worktree - Sub-Agent made modifications"
        return 0
    fi

    # Check if commits were made
    local current_branch=$(git branch --show-current)
    local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    local commit_count=$(git rev-list --count HEAD ^"$main_branch" 2>/dev/null || echo "0")

    if [[ "$commit_count" -gt 0 ]]; then
        log INFO "Found $commit_count new commit(s) in worktree"
        return 0
    fi

    log WARN "No changes or commits detected in worktree"
    return 1
}

# Main execution
main() {
    log INFO "PostToolUse(Task) hook triggered - Cleaning up Sub-Agent worktree"

    # Parse input
    parse_task_result

    # Find the most recent agent worktree
    local agent_worktree_path=$(find_recent_agent_worktree "$SUBAGENT_TYPE")

    if [[ -z "$agent_worktree_path" ]]; then
        log WARN "No agent worktree found for: $SUBAGENT_TYPE"
        log INFO "Skipping cleanup - may have been manually cleaned up"
        exit 0
    fi

    log INFO "Found agent worktree: $agent_worktree_path"

    # Change to worktree directory to perform checks
    cd "$agent_worktree_path" || {
        log ERROR "Failed to enter worktree directory: $agent_worktree_path"
        exit 1
    }

    # Check if Sub-Agent execution was successful
    if check_execution_success; then
        log SUCCESS "Sub-Agent execution completed successfully"

        # Prompt for cleanup/merge
        log INFO "Initiating worktree cleanup and merge..."

        if cleanup_task_worktree false; then
            log SUCCESS "Worktree cleanup complete - changes merged to main"

            # VOICEVOX notification (macOS only)
            if [[ "$OSTYPE" == "darwin"* ]] && command -v osascript &>/dev/null; then
                osascript -e "display notification \"Cleanup complete for $SUBAGENT_TYPE\" with title \"Miyabi Orchestrator\" sound name \"Frog\"" 2>/dev/null || true
            fi
        else
            log ERROR "Cleanup failed - manual intervention required"
            log WARN "Worktree preserved at: $agent_worktree_path"
            exit 1
        fi
    else
        log WARN "Sub-Agent execution may have failed or made no changes"
        log WARN "Preserving worktree for manual inspection: $agent_worktree_path"
        log INFO "To manually cleanup: cd $agent_worktree_path && .claude/hooks/worktree-manager.sh cleanup"
    fi

    return 0
}

# Run main
main
