#!/bin/bash
# codex-monitor.sh - Codex Process Monitor with Auto-Recovery
# Version: 1.0.0
# Description: Monitors Claude Code CLI process and triggers hooks on halt events

set -euo pipefail

# ============================================================
# Configuration
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/halt-monitor.json"

# Default configuration (overridden by config file)
SILENCE_THRESHOLD=30
MAX_RESTARTS=3
COOLDOWN_SECONDS=60
ENABLED=true

# Log setup
LOG_DIR="$PROJECT_ROOT/.ai/logs"
MONITOR_LOG="$LOG_DIR/codex-monitor-$(date +%Y-%m-%d).log"
EVENT_LOG="$LOG_DIR/codex-events-$(date +%Y-%m-%d).log"

mkdir -p "$LOG_DIR"

# Temp files
STDOUT_LOG="/tmp/codex-stdout-$$.log"
STDERR_LOG="/tmp/codex-stderr-$$.log"
LAST_ACTIVITY="/tmp/codex-last-activity-$$"
RESTART_COUNT_FILE="/tmp/miyabi-codex-restart-count"
SESSION_ID="/tmp/miyabi-session-id"

# ============================================================
# Logging Functions
# ============================================================

log() {
  local level="$1"
  shift
  local msg="$*"
  echo "[$(date -Iseconds)] [$level] $msg" | tee -a "$MONITOR_LOG"
}

log_event() {
  local event_type="$1"
  local severity="$2"
  shift 2
  local details="$*"

  cat >> "$EVENT_LOG" <<EOF
{
  "timestamp": "$(date -Iseconds)",
  "type": "$event_type",
  "severity": "$severity",
  "details": "$details",
  "sessionId": "$(cat "$SESSION_ID" 2>/dev/null || echo 'unknown')"
}
EOF
}

# ============================================================
# Configuration Loading
# ============================================================

load_config() {
  if [ -f "$CONFIG_FILE" ]; then
    log "INFO" "Loading configuration from $CONFIG_FILE"

    # Parse JSON config (requires jq)
    if command -v jq &>/dev/null; then
      ENABLED=$(jq -r '.codexHaltMonitor.enabled // true' "$CONFIG_FILE")
      SILENCE_THRESHOLD=$(jq -r '.codexHaltMonitor.silenceThreshold // 30' "$CONFIG_FILE")
      MAX_RESTARTS=$(jq -r '.codexHaltMonitor.maxRestarts // 3' "$CONFIG_FILE")
      COOLDOWN_SECONDS=$(jq -r '.codexHaltMonitor.cooldownSeconds // 60' "$CONFIG_FILE")
    else
      log "WARN" "jq not found, using default configuration"
    fi
  else
    log "INFO" "Config file not found, using defaults"
  fi

  log "INFO" "Configuration: enabled=$ENABLED, silence_threshold=${SILENCE_THRESHOLD}s, max_restarts=$MAX_RESTARTS"
}

# ============================================================
# Event Detection Functions
# ============================================================

detect_fatal_error() {
  local line="$1"

  # Fatal error patterns
  local patterns=(
    "Codex crashed"
    "Unhandled rejection"
    "Fatal error"
    "ECONNREFUSED"
    "SIGTERM"
    "SIGKILL"
    "Rate limit exceeded"
    "429 Too Many Requests"
  )

  for pattern in "${patterns[@]}"; do
    if echo "$line" | grep -iq "$pattern"; then
      log "ERROR" "Fatal error detected: $pattern"
      log_event "fatal_error" "P0" "pattern=$pattern, message=$line"
      return 0
    fi
  done

  return 1
}

detect_warning() {
  local line="$1"

  # Warning patterns
  local patterns=(
    "Out of memory"
    "ENOMEM"
    "Timeout"
    "Connection lost"
  )

  for pattern in "${patterns[@]}"; do
    if echo "$line" | grep -iq "$pattern"; then
      log "WARN" "Warning detected: $pattern"
      log_event "warning" "P1" "pattern=$pattern, message=$line"
      return 0
    fi
  done

  return 1
}

# ============================================================
# Hook Trigger Functions
# ============================================================

trigger_hook() {
  local hook_name="$1"
  local metadata="$2"

  local hook_script="$SCRIPT_DIR/codex-${hook_name}.sh"

  if [ -x "$hook_script" ]; then
    log "INFO" "Triggering hook: $hook_name"
    echo "$metadata" | "$hook_script"
  else
    log "WARN" "Hook script not found or not executable: $hook_script"
  fi
}

handle_fatal_error() {
  local error_msg="$1"

  local metadata=$(cat <<EOF
{
  "eventId": "$(uuidgen 2>/dev/null || echo "$$-$(date +%s)")",
  "reason": "Fatal error detected",
  "severity": "P0",
  "details": {
    "errorMessage": "$error_msg",
    "recentLogs": $(tail -n 10 "$STDOUT_LOG" | jq -R . | jq -s .)
  }
}
EOF
)

  # Trigger hooks
  trigger_hook "restart" "$metadata"
  trigger_hook "notify" "$metadata"
  trigger_hook "debug-collect" "$metadata"
}

handle_process_exit() {
  local exit_code="$1"
  local pid="$2"

  if [ "$exit_code" -ne 0 ]; then
    log "ERROR" "Codex process exited with non-zero code: $exit_code"
    log_event "process_exit" "P0" "exit_code=$exit_code, pid=$pid"

    local metadata=$(cat <<EOF
{
  "eventId": "$(uuidgen 2>/dev/null || echo "$$-$(date +%s)")",
  "reason": "Process exited with code $exit_code",
  "severity": "P0",
  "details": {
    "exitCode": $exit_code,
    "pid": $pid,
    "recentLogs": $(tail -n 10 "$STDOUT_LOG" | jq -R . | jq -s .)
  }
}
EOF
)

    trigger_hook "restart" "$metadata"
    trigger_hook "notify" "$metadata"
    trigger_hook "debug-collect" "$metadata"
  else
    log "INFO" "Codex process exited gracefully (exit code 0)"
    log_event "process_exit" "P2" "exit_code=0, pid=$pid"
  fi
}

handle_silence_timeout() {
  local duration="$1"

  log "WARN" "Silence timeout: no output for ${duration}s (threshold: ${SILENCE_THRESHOLD}s)"
  log_event "silence_timeout" "P1" "duration=${duration}s, threshold=${SILENCE_THRESHOLD}s"

  local metadata=$(cat <<EOF
{
  "eventId": "$(uuidgen 2>/dev/null || echo "$$-$(date +%s)")",
  "reason": "Silence timeout: ${duration}s without output",
  "severity": "P1",
  "details": {
    "duration": $duration,
    "threshold": $SILENCE_THRESHOLD
  }
}
EOF
)

  trigger_hook "notify" "$metadata"
}

# ============================================================
# Process Monitoring
# ============================================================

monitor_stdout() {
  local codex_pid="$1"

  while IFS= read -r line; do
    # Update last activity timestamp
    date +%s > "$LAST_ACTIVITY"

    # Log to stdout and file
    echo "$line" | tee -a "$STDOUT_LOG"

    # Detect fatal errors
    if detect_fatal_error "$line"; then
      handle_fatal_error "$line"
    fi

    # Detect warnings
    detect_warning "$line"
  done
}

monitor_stderr() {
  local codex_pid="$1"

  while IFS= read -r line; do
    # Update last activity timestamp
    date +%s > "$LAST_ACTIVITY"

    # Log to stderr and file
    echo "$line" | tee -a "$STDERR_LOG" >&2

    # Detect fatal errors
    if detect_fatal_error "$line"; then
      handle_fatal_error "$line"
    fi

    # Detect warnings
    detect_warning "$line"
  done
}

monitor_silence() {
  local codex_pid="$1"

  while kill -0 "$codex_pid" 2>/dev/null; do
    sleep 5

    if [ -f "$LAST_ACTIVITY" ]; then
      local last_activity=$(cat "$LAST_ACTIVITY")
      local current_time=$(date +%s)
      local silence_duration=$((current_time - last_activity))

      if [ "$silence_duration" -gt "$SILENCE_THRESHOLD" ]; then
        handle_silence_timeout "$silence_duration"
        # Reset to prevent repeated notifications
        date +%s > "$LAST_ACTIVITY"
      fi
    fi
  done
}

# ============================================================
# Main Process Wrapper
# ============================================================

run_codex() {
  log "INFO" "Starting Codex process monitor"

  # Generate session ID
  uuidgen 2>/dev/null > "$SESSION_ID" || echo "$$-$(date +%s)" > "$SESSION_ID"

  # Initialize last activity
  date +%s > "$LAST_ACTIVITY"

  # Start Codex with stdout/stderr capture
  log "INFO" "Launching: claude code ${*}"

  # Use process substitution to capture both stdout and stderr
  claude code "$@" > >(monitor_stdout $$) 2> >(monitor_stderr $$) &
  local codex_pid=$!

  log "INFO" "Codex PID: $codex_pid"

  # Start silence monitor in background
  monitor_silence "$codex_pid" &
  local silence_monitor_pid=$!

  # Wait for Codex to exit
  wait "$codex_pid"
  local exit_code=$?

  # Kill silence monitor
  kill "$silence_monitor_pid" 2>/dev/null || true

  # Handle exit
  handle_process_exit "$exit_code" "$codex_pid"

  return "$exit_code"
}

# ============================================================
# Cleanup
# ============================================================

cleanup() {
  log "INFO" "Cleaning up monitor"

  # Remove temp files
  rm -f "$STDOUT_LOG" "$STDERR_LOG" "$LAST_ACTIVITY"

  # Reset restart count after cooldown
  if [ -f "$RESTART_COUNT_FILE" ]; then
    local restart_count=$(cat "$RESTART_COUNT_FILE")
    if [ "$restart_count" -gt 0 ]; then
      log "INFO" "Resetting restart count after cooldown"
      (sleep "$COOLDOWN_SECONDS" && rm -f "$RESTART_COUNT_FILE") &
    fi
  fi
}

trap cleanup EXIT

# ============================================================
# Main Entry Point
# ============================================================

main() {
  # Load configuration
  load_config

  if [ "$ENABLED" != "true" ]; then
    log "INFO" "Codex halt monitor is disabled"
    exec claude code "$@"
    return
  fi

  # Run Codex with monitoring
  run_codex "$@"
}

# Run if executed directly
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
  main "$@"
fi
