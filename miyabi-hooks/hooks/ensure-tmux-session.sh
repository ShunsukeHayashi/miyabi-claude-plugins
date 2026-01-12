#!/bin/bash
# 🎭 Ensure tmux Session - Miyabi Orchestra Auto-Startup
# Claude Code起動時に必ずtmuxセッションを確保

set -e

SESSION_NAME="miyabi-full-power"
PROJECT_ROOT="/Users/shunsuke/Dev/miyabi-private"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🎭 Miyabi tmux Session Check${NC}"

# tmuxがインストールされているか確認
if ! command -v tmux &> /dev/null; then
    echo -e "${YELLOW}⚠️  tmux not found. Please install tmux:${NC}"
    echo "  brew install tmux"
    exit 0
fi

# 既にtmuxセッション内にいる場合
if [ -n "$TMUX" ]; then
    echo -e "${GREEN}✅ Already in tmux session: $(tmux display-message -p '#S')${NC}"
    exit 0
fi

# セッションが既に存在するか確認
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo -e "${GREEN}✅ tmux session '$SESSION_NAME' exists${NC}"
    echo -e "${CYAN}📌 To attach: tmux attach -t $SESSION_NAME${NC}"
    exit 0
fi

# セッションを作成
echo -e "${YELLOW}🔄 Creating tmux session '$SESSION_NAME'...${NC}"
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_ROOT"

# Orchestraセットアップスクリプトを実行（セッション内で）
if [ -f "$PROJECT_ROOT/scripts/miyabi-orchestra.sh" ]; then
    echo -e "${CYAN}🎭 Setting up Miyabi Orchestra (5-pane Coding Ensemble)...${NC}"
    tmux send-keys -t "$SESSION_NAME" "cd '$PROJECT_ROOT'" Enter
    sleep 0.5
    tmux send-keys -t "$SESSION_NAME" "./scripts/miyabi-orchestra.sh coding-ensemble" Enter
    sleep 2
    echo -e "${GREEN}✅ Orchestra setup complete!${NC}"
else
    echo -e "${YELLOW}⚠️  Orchestra setup script not found${NC}"
fi

echo -e "${GREEN}✅ tmux session '$SESSION_NAME' created and ready${NC}"
echo -e "${CYAN}📌 To attach: tmux attach -t $SESSION_NAME${NC}"
echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  🎭 Miyabi Orchestra is ready to perform!         ║${NC}"
echo -e "${CYAN}║                                                    ║${NC}"
echo -e "${CYAN}║  Attach to session:                               ║${NC}"
echo -e "${CYAN}║  $ tmux attach -t $SESSION_NAME                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"

exit 0
