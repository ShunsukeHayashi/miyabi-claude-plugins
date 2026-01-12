# /issue-create - GitHub Issue作成コマンド

## 使い方

```bash
/issue-create "タイトル" --type=feature --priority=P1 --body="詳細説明"
```

## パラメータ

- `title`: Issue タイトル (必須)
- `--type`: Issue種別 (feature|bug|refactor) デフォルト: feature
- `--priority`: 優先度 (P0|P1|P2|P3) デフォルト: P2  
- `--body`: Issue本文 (オプション)
- `--labels`: 追加ラベル (カンマ区切り、オプション)
- `--assignee`: 担当者 (オプション)

## 実行内容

1. GitHub APIでIssueを作成
2. 指定されたラベルを自動付与
3. IssueAgentによる自動分析をキューに登録
4. Issue番号とURLを返却

## 実装

このコマンドは`scripts/issue-create-bg.sh`を呼び出してバックグラウンドで実行します。

```bash
bash ~/miyabi-private/scripts/issue-create-bg.sh "$@"
```
