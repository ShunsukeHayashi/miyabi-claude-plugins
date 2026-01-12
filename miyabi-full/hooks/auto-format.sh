#!/bin/bash
# auto-format.sh - 自動フォーマットフック
#
# Usage: Git pre-commitフックまたはClaude Codeフックとして使用
# Git Hook:   ln -s ../../.claude/hooks/auto-format.sh .git/hooks/pre-commit
# Claude:     { "hooks": { "beforeCommit": ".claude/hooks/auto-format.sh" } }
#
# 機能:
# - ESLintによるTypeScript/JavaScriptコード検査
# - Prettierによるコードフォーマット
# - 自動修正可能な問題を修正
# - 修正不能なエラーがある場合はコミットを中断

set -e

echo "🔧 Auto-format hook running..."

# プロジェクトルートに移動
cd "$(git rev-parse --show-toplevel)"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ステージングされたTypeScript/JavaScriptファイルを取得
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$' || true)

if [ -z "$STAGED_FILES" ]; then
  echo "✅ No TypeScript/JavaScript files to format"
  exit 0
fi

echo "📝 Found $(echo "$STAGED_FILES" | wc -l | tr -d ' ') files to check"

# ESLintチェック
echo ""
echo "🔍 Running ESLint..."
ESLINT_EXIT=0
if npm run lint -- --fix $STAGED_FILES 2>&1 | tee /tmp/eslint.log; then
  echo -e "${GREEN}✅ ESLint passed${NC}"
else
  ESLINT_EXIT=$?
  echo -e "${RED}❌ ESLint found issues${NC}"
  cat /tmp/eslint.log
  echo ""
  echo -e "${YELLOW}Tip: Fix ESLint errors manually or run 'npm run lint -- --fix'${NC}"
  exit 1
fi

# Prettierフォーマット
echo ""
echo "✨ Running Prettier..."
if command -v prettier &> /dev/null; then
  echo "$STAGED_FILES" | xargs prettier --write --ignore-unknown
  echo -e "${GREEN}✅ Prettier formatting complete${NC}"
else
  echo -e "${YELLOW}⚠️  Prettier not found, skipping format${NC}"
fi

# フォーマット後のファイルを再ステージング
echo ""
echo "📦 Re-staging formatted files..."
echo "$STAGED_FILES" | xargs git add

echo ""
echo -e "${GREEN}✅ Auto-format complete - ready to commit${NC}"
exit 0
