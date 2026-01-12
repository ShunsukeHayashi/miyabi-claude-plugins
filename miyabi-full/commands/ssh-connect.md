---
description: MUGEN/MAJIN SSH接続・リソース監視・Claude Code リモート実行（v2.0 最適化版）
---

# `/ssh-connect` - SSH Remote Development Command

**Version**: 2.0 | **Last Updated**: 2025-11-11 | **Status**: Production Ready

MUGEN (無限) および MAJIN (魔神) EC2インスタンスへの接続、リソース監視、Claude Codeリモート実行を統合管理。

---

## 🎯 Quick Start

```bash
# ヘルスチェック
/ssh-connect

# リモートでClaude実行
/ssh-connect machine=mugen mode=claude command="cargo build --release"

# リソース監視
/ssh-connect machine=mugen mode=monitor
```

---

## 🖥️ 管理対象マシン

### MUGEN (無限) - Production Ready ✅

```yaml
Type: AWS EC2 r5.4xlarge
Specs:
  CPU: 16 vCPU
  RAM: 128GB
  Storage: 200GB SSD
  OS: Ubuntu 22.04 + Deep Learning AMI
  Region: ap-northeast-1 (Tokyo)

Connection:
  IP: 44.250.27.197
  SSH: ssh mugen
  Key: ~/.ssh/aimovie-dev-key-usw2.pem

Purpose:
  - Heavy build/test execution
  - Parallel Agent execution
  - Benchmark measurements
  - CI/CD environment
```

### MAJIN (魔神) - Coming Soon 🚧

```yaml
Type: AWS EC2 (TBD)
Status: Under Planning
IP: 54.92.67.11 (tentative)
SSH: ssh majin
Purpose: Secondary execution environment
```

---

## 🔧 Parameters

| Parameter | Required | Type | Description | Example |
|-----------|----------|------|-------------|---------|
| `machine` | No | enum | `mugen` / `majin` / `both` (default: `both`) | `machine=mugen` |
| `mode` | No | enum | Execution mode (default: `status`) | `mode=monitor` |
| `command` | Conditional | string | Remote command (`mode=execute\|claude`) | `command="cargo build"` |
| `file` | Conditional | path | File to transfer (`mode=transfer`) | `file="./binary"` |
| `destination` | Conditional | path | Destination path (`mode=transfer`) | `destination="~/bin/"` |
| `permissions` | No | enum | Permission mode for Claude | `permissions=skip` |

### Mode Options

| Mode | Description | Use Case | Command Required |
|------|-------------|----------|------------------|
| `status` | Health check + resource summary | Quick verification | No |
| `monitor` | Detailed resource monitoring | Deep inspection | No |
| `execute` | Execute remote command | General command execution | Yes |
| `claude` | Execute with Claude Code | AI-assisted development | Yes |
| `transfer` | File transfer (scp) | Deploy binaries | file + destination |
| `connect` | Interactive SSH connection | Manual operations | No |

---

## 🚀 Usage Examples

### Example 1: Health Check (Default)

```bash
/ssh-connect

# Output:
# === SSH Connection Status ===
# 🟢 MUGEN: Connected | CPU: 23% | Memory: 35% | Disk: 34%
# 🟢 MAJIN: Connected | CPU: 12% | Memory: 28% | Disk: 23%
```

### Example 2: Detailed Resource Monitoring

```bash
/ssh-connect machine=mugen mode=monitor

# Shows:
# - CPU usage by core
# - Memory breakdown
# - Disk usage per partition
# - Top 10 processes
```

### Example 3: Remote Claude Execution (Recommended)

```bash
# Method 1: With settings file (推奨)
/ssh-connect machine=mugen mode=claude \
  command="claude --settings .claude/settings.json 'cargo build --release'"

# Method 2: With explicit permissions
/ssh-connect machine=mugen mode=claude \
  command="claude --allowed-tools 'Bash(cargo:*)' 'Run tests'"

# Method 3: Skip permissions (isolated environment only)
/ssh-connect machine=mugen mode=claude permissions=skip \
  command="claude --dangerously-skip-permissions -p 'cargo bench'"
```

### Example 4: Standard Remote Execution

```bash
# Rust build
/ssh-connect machine=mugen mode=execute \
  command="cd ~/miyabi-private && cargo build --release"

# Docker operations
/ssh-connect machine=majin mode=execute \
  command="docker ps -a"

# Git operations
/ssh-connect machine=mugen mode=execute \
  command="cd ~/miyabi-private && git pull && git status"
```

### Example 5: File Transfer

```bash
# Upload binary to MUGEN
/ssh-connect machine=mugen mode=transfer \
  file="./target/release/miyabi" \
  destination="~/bin/"

# Upload config
/ssh-connect machine=mugen mode=transfer \
  file=".claude/settings.json" \
  destination="~/miyabi-private/.claude/"
```

### Example 6: Interactive Connection

```bash
/ssh-connect machine=mugen mode=connect

# Opens interactive SSH session
# Useful for:
# - Manual debugging
# - Complex operations
# - Environment setup
```

---

## 🤖 Claude Code Integration

### Safe Execution Pattern

```bash
# Pattern 1: Settings-based (最も安全)
/ssh-connect machine=mugen mode=claude \
  command="cd ~/miyabi-private && \
           claude --settings .claude/settings.json \
                  'Implement Feature X'"

# Pattern 2: Explicit allowlist
/ssh-connect machine=mugen mode=claude \
  command="claude --allowed-tools 'Bash(cargo:*) Bash(git:*) Read Write Edit' \
                  'Fix bug in module Y'"

# Pattern 3: Permission mode
/ssh-connect machine=mugen mode=claude \
  command="claude --permission-mode acceptEdits \
                  'Refactor component Z'"
```

### Dangerous Pattern (Use with Caution)

```bash
# ⚠️ Only for isolated CI/CD containers
/ssh-connect machine=mugen mode=claude permissions=skip \
  command="docker run --rm --network none miyabi-ci \
           'claude --dangerously-skip-permissions -p \"cargo test --all\"'"
```

### tmux Integration

```bash
# Create remote tmux session with Claude
/ssh-connect machine=mugen mode=execute \
  command="tmux new-session -d -s dev \
           'cd ~/miyabi-private && \
            claude --settings .claude/settings.json'"

# Attach to session
/ssh-connect machine=mugen mode=connect

# In SSH session:
tmux attach -t dev
```

---

## 📊 Status Display Format

### Standard Output

```bash
=== SSH Connection Status ===

🟢 MUGEN (無限)
  Status: Connected ✓
  IP: 44.250.27.197
  Uptime: 1 day, 7:00
  Load: 1.05, 1.03, 1.03

  Resources:
    CPU: 16 vCPU | 23% used | 🟢 Normal
    Memory: 128GB | 45GB used (35%) | 🟢 Normal
    Disk: 200GB | 67GB used (34%) | 🟢 Normal

  Top Processes:
    1. cargo build (12% CPU, 4GB RAM)
    2. rustc (8% CPU, 3GB RAM)

🟢 MAJIN (魔神)
  Status: Connected ✓
  IP: 54.92.67.11
  Uptime: 2:45
  Load: 1.11, 0.50, 0.31

  Resources:
    CPU: 8 vCPU | 12% used | 🟢 Normal
    Memory: 64GB | 18GB used (28%) | 🟢 Normal
    Disk: 100GB | 23GB used (23%) | 🟢 Normal

=== All systems operational ===
```

### Warning Indicators

```
🟡 Warning: CPU > 80%
🟡 Warning: Memory > 85%
🟡 Warning: Disk > 90%
🔴 Critical: Any > 95%
```

---

## 🛡️ Security & Safety

### Command Whitelist (mode=execute)

**✅ Allowed Commands**:
```bash
# System
cd, ls, pwd, cat, grep, find, echo, mkdir

# Development
cargo build, cargo test, cargo clippy, cargo bench
npm install, npm run, npm test
rustc, rustup

# Git
git status, git log, git diff, git pull, git push

# Docker
docker ps, docker images, docker logs, docker run

# Monitoring
htop, top, free, df, uptime, ps

# tmux
tmux list-sessions, tmux attach, tmux new-session
```

**❌ Blocked Commands**:
```bash
# Destructive
rm -rf, shutdown, reboot, halt, poweroff

# Disk operations
dd, mkfs, fdisk, parted

# Network/Security
iptables, ufw disable, netfilter

# System modification
chroot, systemctl stop, kill -9 1
```

### SSH Security

```yaml
Authentication:
  - Public key only
  - No password authentication

Key Permissions:
  - Must be 600 (rw-------)
  - Auto-check before connection

Connection:
  - Timeout: 5 seconds
  - ServerAliveInterval: 60s
  - StrictHostKeyChecking: no (dev environment)

Logging:
  - All commands logged to ~/.ssh/command.log
  - Audit trail enabled
```

### Claude Permission Modes

| Mode | Safety Level | Use Case | Command |
|------|--------------|----------|---------|
| **Settings-based** | ✅✅✅ High | Production | `--settings .claude/settings.json` |
| **Explicit allowlist** | ✅✅ Medium | Development | `--allowed-tools "Bash(cargo:*)"` |
| **Permission mode** | ✅ Low | Quick tasks | `--permission-mode acceptEdits` |
| **Skip permissions** | ⚠️⚠️⚠️ Very Low | CI/CD only | `--dangerously-skip-permissions` |

---

## 🔍 Troubleshooting

### Issue: Connection Timeout

**Symptoms**:
```
Error: Connection to mugen timed out
```

**Solutions**:
```bash
# 1. Check instance status
aws ec2 describe-instances --instance-ids i-xxxxx

# 2. Check network
ping 44.250.27.197

# 3. Check security group
# Ensure port 22 is open from your IP

# 4. Restart instance (if needed)
aws ec2 reboot-instances --instance-ids i-xxxxx
```

### Issue: Permission Denied

**Symptoms**:
```
Permission denied (publickey)
```

**Solutions**:
```bash
# 1. Check key permissions
ls -l ~/.ssh/aimovie-dev-key-usw2.pem

# 2. Fix permissions
chmod 600 ~/.ssh/aimovie-dev-key-usw2.pem

# 3. Verify SSH config
cat ~/.ssh/config | grep -A 10 "^Host mugen"

# 4. Test with explicit key
ssh -i ~/.ssh/aimovie-dev-key-usw2.pem ubuntu@44.250.27.197
```

### Issue: Claude Command Not Found

**Symptoms**:
```
bash: claude: command not found
```

**Solutions**:
```bash
# 1. Install Claude Code
/ssh-connect machine=mugen mode=execute \
  command="npm install -g @anthropic-ai/claude-code"

# 2. Check PATH
/ssh-connect machine=mugen mode=execute \
  command="echo \$PATH"

# 3. Verify installation
/ssh-connect machine=mugen mode=execute \
  command="which claude && claude --version"
```

### Issue: Disk Full

**Symptoms**:
```
No space left on device
```

**Solutions**:
```bash
# 1. Check disk usage
/ssh-connect machine=mugen mode=monitor

# 2. Find large directories
/ssh-connect machine=mugen mode=execute \
  command="du -h ~/ | sort -rh | head -20"

# 3. Clean target directory
/ssh-connect machine=mugen mode=execute \
  command="cd ~/miyabi-private && cargo clean"

# 4. Clean Docker
/ssh-connect machine=mugen mode=execute \
  command="docker system prune -af"
```

---

## 📈 Performance Optimization

### Build Time Comparison

| Task | Local (M2 Mac) | MUGEN | Speedup |
|------|----------------|-------|---------|
| `cargo build --release` | 180s | 45s | **4.0x** |
| `cargo test --all` | 120s | 30s | **4.0x** |
| `cargo bench` | 300s | 60s | **5.0x** |

### Best Practices

```bash
# 1. Use tmux for long-running tasks
/ssh-connect machine=mugen mode=execute \
  command="tmux new-session -d -s build 'cargo build --release'"

# 2. Background execution with nohup
/ssh-connect machine=mugen mode=execute \
  command="nohup cargo bench > bench.log 2>&1 &"

# 3. Parallel execution
/ssh-connect machine=mugen mode=execute \
  command="cargo test --jobs 16"
```

---

## 📚 Related Documentation

- **Complete Guide**: `.claude/SSH_REMOTE_DEVELOPMENT_GUIDE.md`
- **Infrastructure**: `docs/infrastructure/MUGEN_MACHINE_OVERVIEW.md`
- **Machine Config**: `.miyabi/infrastructure/machines.toml`
- **Setup Guide**: `EC2-Setup-Package/QUICK_START.md`

---

## ✅ Pre-Execution Checklist

- [ ] SSH connection verified: `/ssh-connect mode=status`
- [ ] Key permissions correct: `ls -l ~/.ssh/*.pem`
- [ ] Project exists on remote: `ls ~/miyabi-private`
- [ ] Settings file synced: `scp .claude/settings.json mugen:~/miyabi-private/.claude/`
- [ ] Resource available: CPU < 80%, Memory < 80%, Disk < 90%
- [ ] Command whitelisted (if using `mode=execute`)
- [ ] Permission strategy decided (settings vs allowlist vs skip)

---

## 🎯 Quick Reference Card

```bash
# === Basic Operations ===
/ssh-connect                                    # Health check
/ssh-connect machine=mugen mode=monitor         # Resource monitor
/ssh-connect machine=mugen mode=connect         # Interactive SSH

# === Claude Execution (Recommended) ===
/ssh-connect machine=mugen mode=claude \
  command="claude --settings .claude/settings.json 'Task'"

# === Remote Execution ===
/ssh-connect machine=mugen mode=execute \
  command="cd ~/miyabi-private && cargo build"

# === File Transfer ===
/ssh-connect machine=mugen mode=transfer \
  file="./binary" destination="~/bin/"

# === Emergency ===
/ssh-connect machine=mugen mode=execute \
  command="tmux kill-server"  # Kill all tmux sessions
```

---

## 🎉 Advanced Workflows

### Workflow 1: Full CI/CD Pipeline

```bash
# Step 1: Pre-flight check
/ssh-connect

# Step 2: Sync code
/ssh-connect machine=mugen mode=execute \
  command="cd ~/miyabi-private && git pull"

# Step 3: Build
/ssh-connect machine=mugen mode=claude \
  command="claude --settings .claude/settings.json \
                  'cargo build --release'"

# Step 4: Test
/ssh-connect machine=mugen mode=execute \
  command="cd ~/miyabi-private && cargo test --all"

# Step 5: Deploy
/ssh-connect machine=mugen mode=transfer \
  file="./deploy.sh" destination="~/scripts/"
/ssh-connect machine=mugen mode=execute \
  command="bash ~/scripts/deploy.sh"
```

### Workflow 2: Parallel Development

```bash
# Main machine: MUGEN
/ssh-connect machine=mugen mode=claude \
  command="tmux new -d -s main 'claude --settings .claude/settings.json'"

# Secondary machine: MAJIN
/ssh-connect machine=majin mode=claude \
  command="tmux new -d -s secondary 'claude --settings .claude/settings.json'"

# Monitor both
watch -n 5 '/ssh-connect mode=status'
```

---

**Status**: Production Ready
**Maintained by**: Miyabi Infrastructure Team
**Last Tested**: 2025-11-11
**Version**: 2.0.0

**MUGEN (無限)** と **MAJIN (魔神)** - Miyabiの無限の可能性を支える開発インフラ 🔥💪
