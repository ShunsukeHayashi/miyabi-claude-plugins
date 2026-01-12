#!/bin/bash
# Miyabi Hooks Library
# Portable version for plugin distribution

miyabi_session_end_report() {
  echo "📊 Session End Report"
  echo "===================="

  # Git status summary
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    echo ""
    echo "📁 Git Status:"
    git status --short 2>/dev/null | head -10

    # Recent commits
    echo ""
    echo "📝 Recent Commits:"
    git log --oneline -5 2>/dev/null
  fi

  echo ""
  echo "✅ Session completed"
}

miyabi_task_complete() {
  local task_name="$1"
  local task_result="$2"

  echo "✅ Task Complete: $task_name"
  [ -n "$task_result" ] && echo "   Result: $task_result"
}

# Export functions
export -f miyabi_session_end_report
export -f miyabi_task_complete
