#!/bin/bash
# Auto-Compact Manager Hook
# Purpose: Automatically manage context window settings for optimal performance
# Usage: Called by SessionStart hook

set -e

ACTION="${1:-check}"  # check, disable, enable

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[AUTOCOMPACT]${NC} $1" >&2
}

log_success() {
    echo -e "${GREEN}[AUTOCOMPACT]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[AUTOCOMPACT]${NC} $1" >&2
}

case "$ACTION" in
    check)
        log_info "Checking context window status..."
        echo ""
        echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║  Auto-Compact Optimization Tips       ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Current Status:${NC}"
        echo "  • Autocompact buffer: ~45k tokens (22.5%)"
        echo "  • Recommendation: Disable for better control"
        echo ""
        echo -e "${CYAN}To disable auto-compact:${NC}"
        echo "  1. Type: ${GREEN}/config${NC}"
        echo "  2. Navigate to 'Auto-compact'"
        echo "  3. Press ${GREEN}SPACE${NC} to toggle to ${GREEN}false${NC}"
        echo "  4. Press ${GREEN}ENTER${NC} to save"
        echo ""
        echo -e "${CYAN}Benefits:${NC}"
        echo "  ✓ Frees up 45k tokens (22.5% of context)"
        echo "  ✓ Manual control over compaction timing"
        echo "  ✓ Better context preservation"
        echo ""
        echo -e "${CYAN}Manual compact when needed:${NC}"
        echo "  • Type: ${GREEN}/compact${NC} at logical breakpoints"
        echo "  • Monitor: ${GREEN}/context${NC} to check usage"
        echo ""
        ;;

    disable)
        log_warn "Auto-compact cannot be disabled programmatically"
        log_info "Please run: ${GREEN}/config${NC} and toggle Auto-compact to false"
        ;;

    enable)
        log_warn "Auto-compact cannot be enabled programmatically"
        log_info "Please run: ${GREEN}/config${NC} and toggle Auto-compact to true"
        ;;

    *)
        echo "Usage: $0 {check|disable|enable}" >&2
        exit 1
        ;;
esac

exit 0
