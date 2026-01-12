#!/bin/bash
# Worktree Prompt - Interactive Task Name Collection
# Version: 1.0.0
# Usage: Called by SessionStart hook

set -euo pipefail

# Source worktree manager functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/worktree-manager.sh"

# Color codes (prefix with W_ to avoid conflicts)
readonly W_CYAN='\033[0;36m'
readonly W_GREEN='\033[0;32m'
readonly W_YELLOW='\033[1;33m'
readonly W_BLUE='\033[0;34m'
readonly W_NC='\033[0m'

# Interactive prompt for task name
prompt_task_name() {
    echo ""
    echo -e "${W_CYAN}╔════════════════════════════════════════════════╗${W_NC}"
    echo -e "${W_CYAN}║       Miyabi Worktree Automation              ║${W_NC}"
    echo -e "${W_CYAN}╚════════════════════════════════════════════════╝${W_NC}"
    echo ""

    # Check if already in a worktree
    if is_in_worktree; then
        local current_worktree=$(get_current_worktree_name)
        echo -e "${W_YELLOW}ℹ️  Already in worktree: ${current_worktree}${W_NC}"
        echo ""

        # Ask if user wants to continue or cleanup
        echo -e "${W_BLUE}What would you like to do?${W_NC}"
        echo "  1) Continue in current worktree"
        echo "  2) Cleanup and start new worktree"
        echo "  3) Skip worktree management"
        echo ""
        read -p "Choice [1-3]: " -r choice

        case "$choice" in
            1)
                echo -e "${W_GREEN}✅ Continuing in current worktree${W_NC}"
                return 0
                ;;
            2)
                echo -e "${W_YELLOW}⚠️  Cleaning up current worktree...${W_NC}"
                cleanup_task_worktree false || {
                    echo -e "${W_YELLOW}⚠️  Cleanup failed. Continuing in current worktree.${W_NC}"
                    return 1
                }
                # Continue to prompt for new task
                ;;
            3|*)
                echo -e "${W_BLUE}ℹ️  Skipping worktree management${W_NC}"
                return 0
                ;;
        esac
    fi

    # Prompt for task description
    echo -e "${W_BLUE}What task are you working on?${W_NC}"
    echo "  (Describe in a few words, e.g., 'fix auth bug', 'add logging')"
    echo "  Or type 'skip' to continue without creating a worktree"
    echo ""
    read -p "Task: " -r task_input

    # Check for skip/cancel
    case "${task_input,,}" in
        skip|no|cancel|"")
            echo -e "${W_BLUE}ℹ️  Skipping worktree creation${W_NC}"
            return 0
            ;;
        quit|exit)
            echo -e "${W_YELLOW}⚠️  Exiting session${W_NC}"
            exit 0
            ;;
    esac

    # Optional: prompt for issue number
    echo ""
    echo -e "${W_BLUE}Related GitHub Issue number? (optional, press Enter to skip)${W_NC}"
    read -p "Issue #: " -r issue_input

    # Clean issue number input
    issue_number=$(echo "$issue_input" | sed 's/[^0-9]//g')

    # Create worktree
    echo ""
    echo -e "${W_YELLOW}🔧 Creating worktree...${W_NC}"
    echo ""

    if create_task_worktree "$task_input" "$issue_number"; then
        echo ""
        echo -e "${W_GREEN}✅ Worktree created successfully!${W_NC}"
        echo -e "${W_GREEN}📍 You are now in: $(pwd)${W_NC}"
        echo ""

        # Show git status
        echo -e "${W_BLUE}📊 Git Status:${W_NC}"
        git status --short || true
        echo ""

        return 0
    else
        echo ""
        echo -e "${W_YELLOW}⚠️  Worktree creation failed or skipped${W_NC}"
        echo ""
        return 1
    fi
}

# Show existing worktrees
show_existing_worktrees() {
    echo ""
    echo -e "${W_BLUE}📂 Existing Worktrees:${W_NC}"
    echo ""

    if ! git worktree list 2>/dev/null | tail -n +2 | grep -q .; then
        echo "  (none)"
        return 0
    fi

    git worktree list | tail -n +2 | while read -r line; do
        echo "  $line"
    done

    echo ""
}

# Show stale worktrees reminder
show_stale_reminder() {
    local stale_output
    stale_output=$(list_stale_worktrees 7 2>/dev/null || true)
    local stale_count=$(echo "$stale_output" | grep -c "🗑️  Stale worktree:" || echo "0")

    if [[ "$stale_count" -gt 0 ]]; then
        echo ""
        echo -e "${W_YELLOW}⚠️  You have $stale_count stale worktree(s) (older than 7 days)${W_NC}"
        echo -e "${W_YELLOW}   Run: .claude/hooks/worktree-manager.sh list-stale${W_NC}"
        echo -e "${W_YELLOW}   Or cleanup: .claude/hooks/worktree-manager.sh auto-cleanup${W_NC}"
        echo ""
    fi
}

# Main entry point
main() {
    # Show existing worktrees
    show_existing_worktrees

    # Show stale reminder
    show_stale_reminder

    # Prompt for task
    prompt_task_name

    # Return success
    return 0
}

# Run main if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
