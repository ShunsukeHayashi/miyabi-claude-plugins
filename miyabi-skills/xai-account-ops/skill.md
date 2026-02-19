---
name: xai-account-ops
description: xAI APIを使ったXアカウント運用支援スキル。アカウント分析、トレンド検索、競合分析、改善提案を自動化。
---

# xAI Account Operations スキル

## 概要

xAI API（Grok-4）を使ったX（Twitter）アカウント運用支援スキルです。

## 機能

### 1. アカウント分析 (`analyze`)
特定アカウントの最新投稿を分析し、エンゲージメント傾向を把握します。

```bash
./run.sh analyze The_AGI_WAY
```

### 2. トレンド検索 (`trend`)
キーワードでバズっている投稿を検索します。

```bash
./run.sh trend "Claude Code"
```

### 3. 競合分析 (`competitor`)
複数アカウントを比較分析します。

```bash
./run.sh competitor "satori_sz9,ai_and_and"
```

### 4. 改善提案 (`suggest`)
アカウントデータに基づく改善提案を生成します。

```bash
./run.sh suggest The_AGI_WAY
```

## API設定

| 項目 | 値 |
|------|-----|
| Base URL | `https://api.x.ai/v1/` |
| Model | `grok-4-fast` |
| Endpoint | `/v1/responses` (X Search) |
| API Key | `$XAI_API_KEY` 環境変数 |

## 使用例

### アカウント分析
```bash
source ~/.config/claude-env/tokens.conf
./run.sh analyze The_AGI_WAY
```

### トレンド検索（期間指定）
```bash
./run.sh trend "Claude Code" "2026-02-01T00:00:00Z" "2026-02-19T23:59:59Z"
```

## 出力先

分析結果は `outputs/xai-account-ops/` に保存されます。

## 依存関係

- `curl` - APIリクエスト
- `jq` - JSON処理

## 注意事項

- APIキーは環境変数 `XAI_API_KEY` で管理
- X Searchコスト: ~$0.005/回 + トークン代
- レート制限に注意（アカウントプランによる）
