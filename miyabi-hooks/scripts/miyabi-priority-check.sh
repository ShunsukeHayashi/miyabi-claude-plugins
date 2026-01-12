#!/bin/bash
# Miyabi Priority Check Script
# Portable version for plugin distribution

VERBOSE=false
JSON=false
ENFORCE=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --verbose) VERBOSE=true; shift ;;
    --json) JSON=true; shift ;;
    --enforce) ENFORCE=true; shift ;;
    *) shift ;;
  esac
done

# Check for gh CLI
if ! command -v gh &> /dev/null; then
  echo "⚠️ gh CLI not installed. Install: brew install gh"
  exit 0
fi

# Get open issues with priority label
PRIORITY_ISSUES=$(gh issue list --label "priority:high" --state open --json number,title,labels 2>/dev/null || echo "[]")

if [ "$JSON" = true ]; then
  echo "{\"priority_issues\": $PRIORITY_ISSUES, \"action_required\": \"review\"}"
  exit 0
fi

if [ "$VERBOSE" = true ]; then
  echo "📋 Priority Check Results:"
  if [ "$PRIORITY_ISSUES" = "[]" ]; then
    echo "✅ No high-priority issues pending"
  else
    echo "⚠️ High-priority issues found:"
    echo "$PRIORITY_ISSUES" | jq -r '.[] | "  #\(.number): \(.title)"'
  fi
fi

if [ "$ENFORCE" = true ] && [ "$PRIORITY_ISSUES" != "[]" ]; then
  exit 1
fi

exit 0
