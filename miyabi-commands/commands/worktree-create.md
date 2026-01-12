# /worktree-create - Worktree作成コマンド

## 使い方
```bash
/worktree-create 886
/worktree-create issue-886 --base=main
```

## 機能
1. git worktree作成
2. ブランチ自動命名 (feat/issue-XXX)
3. 作業ディレクトリ準備

## 実装
```bash
bash ~/miyabi-private/scripts/worktree-create-bg.sh "$@"
```
