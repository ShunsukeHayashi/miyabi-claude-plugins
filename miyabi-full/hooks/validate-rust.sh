#!/bin/bash
# ============================================================================
# Miyabi - Rust Validation Hook
# ============================================================================
# Purpose: Validate Rust code after Edit/Write operations
# Trigger: PostToolUse (Edit|Write)
# Exit Codes: 0 (success), 1 (validation failed)
# ============================================================================

set -e

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
LOG_FILE="${PROJECT_DIR}/.ai/logs/rust-validation.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

echo "🦀 [$(date +'%Y-%m-%d %H:%M:%S')] Running Rust validation..." | tee -a "$LOG_FILE"

# Check if we're in a Rust project
if [ ! -f "Cargo.toml" ]; then
    echo "⚠️  Not a Rust project (no Cargo.toml found)" | tee -a "$LOG_FILE"
    exit 0
fi

# Run cargo check
echo "  → cargo check..." | tee -a "$LOG_FILE"
if cargo check 2>&1 | tee -a "$LOG_FILE" | grep -q "error"; then
    echo "❌ Rust validation failed: compilation errors detected" | tee -a "$LOG_FILE"
    exit 1
fi

# Run cargo clippy (warnings only, don't fail)
echo "  → cargo clippy..." | tee -a "$LOG_FILE"
CLIPPY_OUTPUT=$(cargo clippy 2>&1 || true)
CLIPPY_WARNINGS=$(echo "$CLIPPY_OUTPUT" | grep -c "warning:" || echo "0")

if [ "$CLIPPY_WARNINGS" -gt 0 ]; then
    echo "⚠️  Found $CLIPPY_WARNINGS clippy warning(s)" | tee -a "$LOG_FILE"
    echo "$CLIPPY_OUTPUT" | grep "warning:" | head -5 | tee -a "$LOG_FILE"
else
    echo "✅ No clippy warnings" | tee -a "$LOG_FILE"
fi

echo "✅ Rust validation completed successfully" | tee -a "$LOG_FILE"
exit 0
