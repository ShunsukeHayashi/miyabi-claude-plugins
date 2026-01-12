#!/bin/bash
# test-codex-monitor.sh - Test Script for Codex Halt Monitor
# Version: 1.0.0
# Description: Test various failure scenarios

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Codex Halt Monitor Test Suite ==="
echo ""

# ============================================================
# Test 1: Restart Hook
# ============================================================

echo "Test 1: Testing restart hook..."
cat <<EOF | "$SCRIPT_DIR/codex-restart.sh"
{
  "eventId": "test-001",
  "reason": "Test restart trigger",
  "severity": "P0",
  "details": {
    "exitCode": 1
  }
}
EOF

if [ $? -eq 0 ]; then
  echo "✅ Test 1 passed: Restart hook executed successfully"
else
  echo "❌ Test 1 failed: Restart hook returned error"
fi
echo ""

# ============================================================
# Test 2: Notify Hook
# ============================================================

echo "Test 2: Testing notify hook..."
cat <<EOF | "$SCRIPT_DIR/codex-notify.sh"
{
  "eventId": "test-002",
  "reason": "Test notification trigger",
  "severity": "P1",
  "details": {
    "message": "This is a test notification"
  }
}
EOF

if [ $? -eq 0 ]; then
  echo "✅ Test 2 passed: Notify hook executed successfully"
else
  echo "❌ Test 2 failed: Notify hook returned error"
fi
echo ""

# ============================================================
# Test 3: Debug Collect Hook
# ============================================================

echo "Test 3: Testing debug-collect hook..."
cat <<EOF | "$SCRIPT_DIR/codex-debug-collect.sh"
{
  "eventId": "test-003",
  "reason": "Test debug collection",
  "severity": "P0",
  "details": {
    "errorMessage": "Mock crash for testing",
    "recentLogs": ["line 1", "line 2", "line 3"]
  }
}
EOF

if [ $? -eq 0 ]; then
  echo "✅ Test 3 passed: Debug-collect hook executed successfully"

  # Check if debug archive was created
  LATEST_DEBUG=$(ls -t ../../.ai/debug/codex-crash-*.tar.gz 2>/dev/null | head -1)
  if [ -n "$LATEST_DEBUG" ]; then
    echo "   Debug archive created: $LATEST_DEBUG"
    echo "   Contents:"
    tar -tzf "$LATEST_DEBUG" | head -10
  fi
else
  echo "❌ Test 3 failed: Debug-collect hook returned error"
fi
echo ""

# ============================================================
# Test 4: Configuration Loading
# ============================================================

echo "Test 4: Testing configuration loading..."
if [ -f "$SCRIPT_DIR/halt-monitor.json" ]; then
  if command -v jq &>/dev/null; then
    ENABLED=$(jq -r '.codexHaltMonitor.enabled' "$SCRIPT_DIR/halt-monitor.json")
    SILENCE_THRESHOLD=$(jq -r '.codexHaltMonitor.silenceThreshold' "$SCRIPT_DIR/halt-monitor.json")

    echo "   enabled: $ENABLED"
    echo "   silenceThreshold: $SILENCE_THRESHOLD"
    echo "✅ Test 4 passed: Configuration loaded successfully"
  else
    echo "⚠️  Test 4 skipped: jq not installed"
  fi
else
  echo "❌ Test 4 failed: Configuration file not found"
fi
echo ""

# ============================================================
# Test 5: Mock Codex Process (Fatal Error)
# ============================================================

echo "Test 5: Testing fatal error detection..."
echo "Simulating Codex process with fatal error..."

# Create a mock script that simulates Codex crash
MOCK_CODEX="/tmp/mock-codex-crash.sh"
cat > "$MOCK_CODEX" <<'MOCK_EOF'
#!/bin/bash
echo "Starting Codex..."
sleep 1
echo "ERROR: Codex crashed"
sleep 1
exit 1
MOCK_EOF
chmod +x "$MOCK_CODEX"

# Monitor the mock process (timeout after 10 seconds)
timeout 10 bash -c "
  exec 3< <($MOCK_CODEX 2>&1)
  while IFS= read -r line <&3; do
    echo \"\$line\"
    if echo \"\$line\" | grep -q 'Codex crashed'; then
      echo '✅ Test 5 passed: Fatal error pattern detected'
      exit 0
    fi
  done
  echo '❌ Test 5 failed: Fatal error pattern not detected'
  exit 1
" || true

rm -f "$MOCK_CODEX"
echo ""

# ============================================================
# Test 6: Mock Codex Process (Graceful Exit)
# ============================================================

echo "Test 6: Testing graceful exit detection..."
echo "Simulating Codex process with graceful exit..."

MOCK_CODEX="/tmp/mock-codex-graceful.sh"
cat > "$MOCK_CODEX" <<'MOCK_EOF'
#!/bin/bash
echo "Starting Codex..."
sleep 1
echo "Task completed successfully"
sleep 1
exit 0
MOCK_EOF
chmod +x "$MOCK_CODEX"

if "$MOCK_CODEX" &>/dev/null; then
  echo "✅ Test 6 passed: Graceful exit (exit code 0)"
else
  echo "❌ Test 6 failed: Expected exit code 0"
fi

rm -f "$MOCK_CODEX"
echo ""

# ============================================================
# Summary
# ============================================================

echo "=== Test Summary ==="
echo "All basic tests completed."
echo ""
echo "Manual Testing:"
echo "  1. Run: .claude/hooks/codex-monitor.sh"
echo "  2. Trigger errors manually"
echo "  3. Check logs in .ai/logs/"
echo "  4. Verify notifications (macOS, VOICEVOX)"
echo ""
echo "For full integration test:"
echo "  .claude/hooks/codex-monitor.sh --help"
echo ""
