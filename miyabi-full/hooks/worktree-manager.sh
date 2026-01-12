#!/bin/bash
# Worktree Manager - Automated Worktree Lifecycle Management
# Version: 1.0.0
# Usage: Source this file or call functions directly

set -euo pipefail

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Configuration
readonly WORKTREE_BASE_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}/.worktrees"
readonly LOG_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel)}/.ai/logs"
readonly STALE_DAYS=7
readonly CONTEXT_FILE=".task-context.json"
readonly AGENT_CONTEXT_FILE=".agent-context.json"
readonly LAST_WORKTREE_FILE="$LOG_DIR/.last-worktree-path"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Log function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"

    case "$level" in
        INFO)
            echo -e "${BLUE}ℹ️  $message${NC}" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}✅ $message${NC}" >&2
            ;;
        WARN)
            echo -e "${YELLOW}⚠️  $message${NC}" >&2
            ;;
        ERROR)
            echo -e "${RED}❌ $message${NC}" >&2
            ;;
    esac
}

# Generate worktree name from task description
generate_worktree_name() {
    local task_desc="$1"

    # Convert to lowercase, replace spaces with hyphens, remove special chars
    local worktree_name=$(echo "$task_desc" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9 -]//g' | \
        sed 's/ \+/-/g' | \
        sed 's/^-\+\|-\+$//g' | \
        cut -c1-50)

    echo "$worktree_name"
}

# Check if currently in a worktree
is_in_worktree() {
    local git_dir=$(git rev-parse --git-dir 2>/dev/null || echo "")

    if [[ "$git_dir" == *".git/worktrees"* ]]; then
        return 0
    else
        return 1
    fi
}

# Get current worktree name
get_current_worktree_name() {
    if is_in_worktree; then
        basename "$(pwd)"
    else
        echo ""
    fi
}

# Create worktree for Sub-Agent execution (Orchestrator pattern)
create_subagent_worktree() {
    local subagent_type="$1"
    local task_desc="$2"
    local issue_number="${3:-}"
    local prompt="${4:-}"

    log INFO "Creating Sub-Agent worktree: $subagent_type"

    # Check if already in a worktree (Orchestrator should stay in main)
    if is_in_worktree; then
        local current_worktree=$(get_current_worktree_name)
        log ERROR "Already in worktree: $current_worktree"
        log ERROR "Orchestrator must stay in main branch. Cannot create nested worktree."
        return 1
    fi

    # Generate worktree name based on subagent type
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local worktree_name

    if [[ -n "$issue_number" ]]; then
        worktree_name="${subagent_type}-issue-${issue_number}-${timestamp}"
    else
        worktree_name="${subagent_type}-${timestamp}"
    fi

    local worktree_path="$WORKTREE_BASE_DIR/$worktree_name"
    local branch_name="worktree/$worktree_name"

    # Ensure base directory exists
    mkdir -p "$WORKTREE_BASE_DIR"

    # Create worktree
    log INFO "Creating worktree: $worktree_path"
    if git worktree add "$worktree_path" -b "$branch_name" 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"; then
        log SUCCESS "Worktree created: $worktree_path"
    else
        log ERROR "Failed to create worktree"
        return 1
    fi

    # Create agent context file
    local context_file="$worktree_path/$AGENT_CONTEXT_FILE"
    cat > "$context_file" <<EOF
{
  "subagentType": "$subagent_type",
  "taskDescription": "$task_desc",
  "issueNumber": "${issue_number:-null}",
  "worktreeName": "$worktree_name",
  "worktreePath": "$worktree_path",
  "branchName": "$branch_name",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sessionId": "${MIYABI_SESSION_ID:-unknown}",
  "status": "active",
  "prompt": "$prompt"
}
EOF

    log INFO "Agent context saved: $context_file"

    # Save worktree path for retrieval by pre-hook
    echo "$worktree_path" > "$LAST_WORKTREE_FILE"

    log SUCCESS "Sub-Agent worktree ready: $worktree_path"

    # VOICEVOX notification (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"Worktree created for $subagent_type\" with title \"Miyabi Orchestrator\" sound name \"Glass\"" 2>/dev/null || true
    fi

    return 0
}

# Get the path of the last created worktree
get_last_created_worktree_path() {
    if [[ -f "$LAST_WORKTREE_FILE" ]]; then
        cat "$LAST_WORKTREE_FILE"
    else
        echo ""
    fi
}

# Find the most recent agent worktree for a given subagent type
find_recent_agent_worktree() {
    local subagent_type="$1"

    if [[ ! -d "$WORKTREE_BASE_DIR" ]]; then
        echo ""
        return 1
    fi

    # Find worktrees matching subagent type, sorted by creation time (newest first)
    local worktree_path=$(find "$WORKTREE_BASE_DIR" -mindepth 1 -maxdepth 1 -type d -name "${subagent_type}-*" \
        -exec stat -f "%m %N" {} \; 2>/dev/null | \
        sort -rn | \
        head -1 | \
        cut -d' ' -f2-)

    echo "$worktree_path"
}

# Create worktree based on task name/intent
create_task_worktree() {
    local task_name="$1"
    local issue_number="${2:-}"

    log INFO "Creating worktree for task: $task_name"

    # Check if already in a worktree
    if is_in_worktree; then
        local current_worktree=$(get_current_worktree_name)
        log WARN "Already in worktree: $current_worktree"
        log WARN "Skipping worktree creation. Use cleanup_task_worktree first."
        return 1
    fi

    # Generate worktree name
    local worktree_name=$(generate_worktree_name "$task_name")

    # Add issue number if provided
    if [[ -n "$issue_number" ]]; then
        worktree_name="issue-${issue_number}-${worktree_name}"
    fi

    local worktree_path="$WORKTREE_BASE_DIR/$worktree_name"
    local branch_name="worktree/$worktree_name"

    # Check if worktree already exists
    if [[ -d "$worktree_path" ]]; then
        log WARN "Worktree already exists: $worktree_path"
        log INFO "Switching to existing worktree..."
        cd "$worktree_path"
        return 0
    fi

    # Ensure base directory exists
    mkdir -p "$WORKTREE_BASE_DIR"

    # Create worktree
    log INFO "Creating worktree: $worktree_path"
    if git worktree add "$worktree_path" -b "$branch_name" 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"; then
        log SUCCESS "Worktree created: $worktree_path"
    else
        log ERROR "Failed to create worktree"
        return 1
    fi

    # Create task context file
    local context_file="$worktree_path/$CONTEXT_FILE"
    cat > "$context_file" <<EOF
{
  "taskName": "$task_name",
  "issueNumber": "${issue_number:-null}",
  "worktreeName": "$worktree_name",
  "worktreePath": "$worktree_path",
  "branchName": "$branch_name",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "sessionId": "${MIYABI_SESSION_ID:-unknown}",
  "status": "active"
}
EOF

    log INFO "Task context saved: $context_file"

    # Change to worktree directory
    cd "$worktree_path"
    log SUCCESS "Switched to worktree: $worktree_path"

    # VOICEVOX notification (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"Worktree created: $worktree_name\" with title \"Miyabi Worktree\" sound name \"Glass\"" 2>/dev/null || true
    fi

    return 0
}

# Cleanup and merge worktree after task completion
cleanup_task_worktree() {
    local force="${1:-false}"

    # Check if in a worktree
    if ! is_in_worktree; then
        log WARN "Not in a worktree. Nothing to cleanup."
        return 1
    fi

    local worktree_path=$(pwd)
    local worktree_name=$(basename "$worktree_path")
    local branch_name=$(git branch --show-current)

    log INFO "Cleaning up worktree: $worktree_name"

    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        log WARN "Uncommitted changes detected:"
        git status --short

        if [[ "$force" != "true" ]]; then
            log ERROR "Commit or stash changes before cleanup. Use 'force=true' to override."
            return 1
        else
            log WARN "Force cleanup requested. Changes will be lost!"
        fi
    fi

    # Update task context
    local context_file="$worktree_path/$CONTEXT_FILE"
    if [[ -f "$context_file" ]]; then
        local temp_file=$(mktemp)
        jq '.status = "completed" | .completedAt = "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"' "$context_file" > "$temp_file"
        mv "$temp_file" "$context_file"
    fi

    # Switch back to main branch
    local main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
    local repo_root=$(git rev-parse --show-toplevel)

    log INFO "Switching to main branch: $main_branch"
    cd "$repo_root"
    git checkout "$main_branch" 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"

    # Merge worktree branch
    log INFO "Merging branch: $branch_name"
    if git merge "$branch_name" --no-edit 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"; then
        log SUCCESS "Branch merged successfully"
    else
        log ERROR "Merge failed. Resolve conflicts manually."
        log INFO "Worktree preserved at: $worktree_path"
        return 1
    fi

    # Remove worktree
    log INFO "Removing worktree: $worktree_path"
    if git worktree remove "$worktree_path" --force 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"; then
        log SUCCESS "Worktree removed: $worktree_path"
    else
        log ERROR "Failed to remove worktree"
        return 1
    fi

    # Delete branch
    log INFO "Deleting branch: $branch_name"
    if git branch -D "$branch_name" 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"; then
        log SUCCESS "Branch deleted: $branch_name"
    else
        log WARN "Failed to delete branch (may not exist)"
    fi

    # VOICEVOX notification (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"Worktree cleanup complete\" with title \"Miyabi Worktree\" sound name \"Frog\"" 2>/dev/null || true
    fi

    log SUCCESS "Cleanup complete for worktree: $worktree_name"
    return 0
}

# List stale worktrees (older than STALE_DAYS)
list_stale_worktrees() {
    local stale_days="${1:-$STALE_DAYS}"

    log INFO "Checking for stale worktrees (older than $stale_days days)..."

    if [[ ! -d "$WORKTREE_BASE_DIR" ]]; then
        log INFO "No worktrees directory found"
        return 0
    fi

    local stale_count=0
    local current_time=$(date +%s)
    local stale_threshold=$((current_time - stale_days * 86400))

    while IFS= read -r worktree_dir; do
        if [[ ! -d "$worktree_dir" ]]; then
            continue
        fi

        local context_file="$worktree_dir/$CONTEXT_FILE"
        if [[ -f "$context_file" ]]; then
            local created_at=$(jq -r '.createdAt // empty' "$context_file")
            if [[ -n "$created_at" ]]; then
                local created_timestamp=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" +%s 2>/dev/null || echo "0")

                if [[ $created_timestamp -lt $stale_threshold ]]; then
                    local worktree_name=$(basename "$worktree_dir")
                    local task_name=$(jq -r '.taskName // "unknown"' "$context_file")
                    local age_days=$(( (current_time - created_timestamp) / 86400 ))

                    echo -e "${YELLOW}🗑️  Stale worktree: $worktree_name${NC}"
                    echo "   Task: $task_name"
                    echo "   Age: $age_days days"
                    echo "   Path: $worktree_dir"
                    echo ""

                    stale_count=$((stale_count + 1))
                fi
            fi
        else
            # No context file, check directory mtime
            local dir_mtime=$(stat -f %m "$worktree_dir" 2>/dev/null || echo "0")
            if [[ $dir_mtime -lt $stale_threshold ]]; then
                local worktree_name=$(basename "$worktree_dir")
                local age_days=$(( (current_time - dir_mtime) / 86400 ))

                echo -e "${YELLOW}🗑️  Stale worktree: $worktree_name${NC}"
                echo "   Task: (no context file)"
                echo "   Age: $age_days days"
                echo "   Path: $worktree_dir"
                echo ""

                stale_count=$((stale_count + 1))
            fi
        fi
    done < <(find "$WORKTREE_BASE_DIR" -mindepth 1 -maxdepth 1 -type d)

    if [[ $stale_count -eq 0 ]]; then
        log SUCCESS "No stale worktrees found"
    else
        log INFO "Found $stale_count stale worktree(s)"
    fi

    return 0
}

# Auto-cleanup stale worktrees
auto_cleanup_stale() {
    local stale_days="${1:-$STALE_DAYS}"
    local dry_run="${2:-false}"

    log INFO "Auto-cleanup stale worktrees (older than $stale_days days)..."

    if [[ ! -d "$WORKTREE_BASE_DIR" ]]; then
        log INFO "No worktrees directory found"
        return 0
    fi

    local cleanup_count=0
    local current_time=$(date +%s)
    local stale_threshold=$((current_time - stale_days * 86400))

    while IFS= read -r worktree_dir; do
        if [[ ! -d "$worktree_dir" ]]; then
            continue
        fi

        local context_file="$worktree_dir/$CONTEXT_FILE"
        local is_stale=false

        if [[ -f "$context_file" ]]; then
            local created_at=$(jq -r '.createdAt // empty' "$context_file")
            if [[ -n "$created_at" ]]; then
                local created_timestamp=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created_at" +%s 2>/dev/null || echo "0")

                if [[ $created_timestamp -lt $stale_threshold ]]; then
                    is_stale=true
                fi
            fi
        else
            # No context file, check directory mtime
            local dir_mtime=$(stat -f %m "$worktree_dir" 2>/dev/null || echo "0")
            if [[ $dir_mtime -lt $stale_threshold ]]; then
                is_stale=true
            fi
        fi

        if [[ "$is_stale" == "true" ]]; then
            local worktree_name=$(basename "$worktree_dir")

            if [[ "$dry_run" == "true" ]]; then
                log INFO "[DRY RUN] Would cleanup: $worktree_name"
            else
                log INFO "Cleaning up stale worktree: $worktree_name"

                # Remove worktree
                if git worktree remove "$worktree_dir" --force 2>&1 | tee -a "$LOG_DIR/worktree-$(date +%Y-%m-%d).log"; then
                    log SUCCESS "Removed: $worktree_name"

                    # Try to delete branch
                    local branch_name="worktree/$worktree_name"
                    git branch -D "$branch_name" 2>/dev/null || true

                    cleanup_count=$((cleanup_count + 1))
                else
                    log ERROR "Failed to remove: $worktree_name"
                fi
            fi
        fi
    done < <(find "$WORKTREE_BASE_DIR" -mindepth 1 -maxdepth 1 -type d)

    if [[ "$dry_run" == "true" ]]; then
        log INFO "[DRY RUN] Would cleanup $cleanup_count worktree(s)"
    else
        if [[ $cleanup_count -eq 0 ]]; then
            log SUCCESS "No stale worktrees to cleanup"
        else
            log SUCCESS "Cleaned up $cleanup_count stale worktree(s)"
        fi
    fi

    return 0
}

# Show help
show_help() {
    cat <<EOF
Worktree Manager - Automated Worktree Lifecycle Management

Usage:
  source .claude/hooks/worktree-manager.sh

Functions (Task Management):
  create_task_worktree <task_name> [issue_number]
      Create a new worktree for a task

  cleanup_task_worktree [force]
      Cleanup current worktree and merge to main

Functions (Orchestrator Pattern - NEW):
  create_subagent_worktree <subagent_type> <task_desc> [issue_number] [prompt]
      Create worktree for Sub-Agent execution (called by PreToolUse hook)

  get_last_created_worktree_path
      Get path of the last created worktree

  find_recent_agent_worktree <subagent_type>
      Find most recent worktree for a given subagent type

Functions (Maintenance):
  list_stale_worktrees [days]
      List worktrees older than N days (default: 7)

  auto_cleanup_stale [days] [dry_run]
      Auto-cleanup stale worktrees (default: 7 days)

Functions (Utility):
  is_in_worktree
      Check if currently in a worktree

  get_current_worktree_name
      Get name of current worktree

Examples (Task Management):
  create_task_worktree "fix auth bug" 123
  cleanup_task_worktree

Examples (Orchestrator Pattern):
  create_subagent_worktree "CodeGenAgent" "Implement feature X" 123 "prompt text"
  find_recent_agent_worktree "CodeGenAgent"

Examples (Maintenance):
  list_stale_worktrees 14
  auto_cleanup_stale 7 true  # dry run

Configuration:
  WORKTREE_BASE_DIR: ${WORKTREE_BASE_DIR}
  LOG_DIR: ${LOG_DIR}
  STALE_DAYS: ${STALE_DAYS}
  AGENT_CONTEXT_FILE: ${AGENT_CONTEXT_FILE}
EOF
}

# Main entry point (if script is executed directly)
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]] || [[ -z "${BASH_SOURCE[0]:-}" ]]; then
    case "${1:-help}" in
        create)
            create_task_worktree "${2:-}" "${3:-}"
            ;;
        cleanup)
            cleanup_task_worktree "${2:-false}"
            ;;
        list-stale)
            list_stale_worktrees "${2:-$STALE_DAYS}"
            ;;
        auto-cleanup)
            auto_cleanup_stale "${2:-$STALE_DAYS}" "${3:-false}"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo "Unknown command: $1" >&2
            show_help
            exit 1
            ;;
    esac
fi
