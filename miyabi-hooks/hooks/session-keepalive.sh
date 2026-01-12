#!/bin/bash
# =============================================================================
# Session Keep-Alive Hook
# =============================================================================
# Purpose: Prevent session timeout by periodic health checks
# Trigger: Background process monitoring session activity
# Version: 1.0.0
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
KEEPALIVE_INTERVAL="${KEEPALIVE_INTERVAL:-120}"  # 2 minutes
SESSION_LOG_DIR="${SESSION_LOG_DIR:-.ai/logs}"
KEEPALIVE_LOG="${SESSION_LOG_DIR}/session-keepalive.log"
SESSION_STATE_FILE="/tmp/miyabi-session-state.json"

# -----------------------------------------------------------------------------
# Logging Function
# -----------------------------------------------------------------------------
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${KEEPALIVE_LOG}"
}

# -----------------------------------------------------------------------------
# Health Check Function
# -----------------------------------------------------------------------------
check_health() {
    log "INFO" "🏥 Performing health check..."

    # Check MCP server connection
    if pgrep -f "mcp-server" > /dev/null; then
        log "INFO" "✅ MCP server is running"
    else
        log "WARN" "⚠️  MCP server is not running"
        return 1
    fi

    # Check git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        log "INFO" "✅ Git repository is accessible"
    else
        log "WARN" "⚠️  Git repository is not accessible"
        return 1
    fi

    # Update session state
    update_session_state

    return 0
}

# -----------------------------------------------------------------------------
# Session State Management
# -----------------------------------------------------------------------------
update_session_state() {
    local current_time
    current_time=$(date +%s)

    cat > "${SESSION_STATE_FILE}" <<EOF
{
  "lastActivity": ${current_time},
  "lastHealthCheck": ${current_time},
  "sessionId": "${CLAUDE_SESSION_ID:-unknown}",
  "workingDir": "$(pwd)",
  "gitBranch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
  "gitCommit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
}
EOF

    log "DEBUG" "📝 Updated session state: ${SESSION_STATE_FILE}"
}

# -----------------------------------------------------------------------------
# Background Keep-Alive Loop
# -----------------------------------------------------------------------------
start_keepalive() {
    log "INFO" "🚀 Starting session keep-alive (interval: ${KEEPALIVE_INTERVAL}s)"

    # Create log directory if not exists
    mkdir -p "${SESSION_LOG_DIR}"

    # Initial state
    update_session_state

    # Background loop
    while true; do
        sleep "${KEEPALIVE_INTERVAL}"

        if check_health; then
            log "INFO" "✅ Health check passed"
        else
            log "ERROR" "❌ Health check failed - attempting recovery"
            # Trigger recovery if needed
            attempt_recovery
        fi
    done &

    # Store PID for cleanup
    echo $! > /tmp/miyabi-keepalive.pid
    log "INFO" "🎯 Keep-alive process started (PID: $!)"
}

# -----------------------------------------------------------------------------
# Recovery Function
# -----------------------------------------------------------------------------
attempt_recovery() {
    log "WARN" "🔧 Attempting session recovery..."

    # Try to reconnect MCP server
    if ! pgrep -f "mcp-server" > /dev/null; then
        log "INFO" "🔄 Restarting MCP server..."
        # Add MCP server restart logic here if available
    fi

    # Send notification
    if command -v osascript > /dev/null; then
        osascript -e 'display notification "Session health check failed - recovery attempted" with title "Miyabi Session Monitor"'
    fi
}

# -----------------------------------------------------------------------------
# Stop Keep-Alive
# -----------------------------------------------------------------------------
stop_keepalive() {
    if [ -f /tmp/miyabi-keepalive.pid ]; then
        local pid
        pid=$(cat /tmp/miyabi-keepalive.pid)
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            log "INFO" "🛑 Stopped keep-alive process (PID: $pid)"
        fi
        rm -f /tmp/miyabi-keepalive.pid
    fi
}

# -----------------------------------------------------------------------------
# Main Entry Point
# -----------------------------------------------------------------------------
main() {
    case "${1:-start}" in
        start)
            start_keepalive
            ;;
        stop)
            stop_keepalive
            ;;
        check)
            check_health
            ;;
        *)
            echo "Usage: $0 {start|stop|check}"
            exit 1
            ;;
    esac
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    main "$@"
fi
