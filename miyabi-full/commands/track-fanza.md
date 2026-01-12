# /track-fanza - FANZA新着作品トラッキング

**カテゴリ**: データ収集・分析
**目的**: FANZA（旧DMM.R18）の新着作品情報を取得し、Markdown形式で保存

---

## 📋 概要

DMM Web APIを使用してFANZAの新着動画作品情報を取得し、日次レポートとして保存します。

---

## 🎯 実行内容

```bash
# 環境変数の読み込み
if [ -f ".env.fanza" ]; then
  source .env.fanza
  echo "✅ API設定を読み込みました"
else
  echo "❌ .env.fanza が見つかりません"
  echo ""
  echo "📝 セットアップ手順:"
  echo "   1. テンプレートをコピー:"
  echo "      cp .env.fanza.template .env.fanza"
  echo ""
  echo "   2. .env.fanza を編集してAPI情報を入力"
  echo ""
  echo "   3. DMM API ID/Affiliate IDの取得方法:"
  echo "      https://affiliate.dmm.com/ から申請"
  echo ""
  exit 1
fi

# VOICEVOXスクリプト検出
if [ -f "tools/voicevox_enqueue.sh" ]; then
  VOICE="tools/voicevox_enqueue.sh"
else
  VOICE="echo"
fi

# 開始通知
$VOICE "ファンザ新着作品の取得を開始します！" 1 1.0

# スクリプト実行
HITS="${1:-20}"
./tools/fanza_fetch_new_releases.sh "$HITS"

# 結果確認
LATEST_MD=$(ls -t data/fanza/new_releases_*.md | head -1)
LATEST_JSON=$(ls -t data/fanza/new_releases_*.json | head -1)

if [ -f "$LATEST_MD" ]; then
  echo ""
  echo "📄 生成されたファイル:"
  echo "   Markdown: $LATEST_MD"
  echo "   JSON: $LATEST_JSON"
  echo ""
  echo "📊 取得作品数:"
  grep -c "^## " "$LATEST_MD" || echo "0"
  echo ""
  echo "🔍 プレビュー（最初の3作品）:"
  head -80 "$LATEST_MD"

  # 完了通知
  COUNT=$(grep -c "^## " "$LATEST_MD" || echo "0")
  $VOICE "取得完了！${COUNT}作品の情報を保存しました。" 1 1.0
else
  echo "❌ ファイル生成に失敗しました"
  $VOICE "エラーが発生しました。ログを確認してください。" 1 1.0
  exit 1
fi
```

---

## 🚀 使用方法

### 基本実行（デフォルト20件）

```bash
/track-fanza
```

### 取得件数を指定

```bash
/track-fanza 50
# → 50件の新着作品を取得
```

---

## 🔧 前提条件

### 必須
1. **DMM API設定ファイル**: `.env.fanza`
   ```bash
   DMM_API_ID=your_api_id
   DMM_AFFILIATE_ID=your_affiliate_id
   ```

2. **取得スクリプト**: `tools/fanza_fetch_new_releases.sh`

### オプション
- VOICEVOX Engine（音声実況用）

---

## 📁 出力ファイル

### ディレクトリ構造
```
data/fanza/
├── new_releases_20251027.md   # Markdown形式（人間可読）
├── new_releases_20251027.json # JSON形式（機械処理用）
├── new_releases_20251028.md
└── new_releases_20251028.json
```

### Markdown形式例
```markdown
# FANZA 新着作品 - 2025年10月27日

**取得日時**: 2025-10-27 14:30:00
**取得件数**: 20件

---

## [作品タイトル]

- **品番**: ABC-123
- **発売日**: 2025-10-27
- **価格**: ¥3,980
- **レビュー**: 12件 (平均: 4.5点)
- **URL**: https://...

![サムネイル](https://...)

---
```

---

## 🐛 トラブルシューティング

### Q: `.env.fanza` が見つからない

```bash
# テンプレートからコピー
cp .env.fanza.template .env.fanza

# 編集
vim .env.fanza  # または nano, VSCode等
```

### Q: API IDの取得方法

1. **DMM Affiliate登録**: https://affiliate.dmm.com/
2. **API利用申請**: 管理画面から「API利用」を選択
3. **API ID発行**: 申請後にAPI ID/Affiliate IDが発行される

### Q: APIエラーが発生する

```bash
# JSONレスポンスを確認
cat data/fanza/new_releases_$(date +%Y%m%d).json | jq .

# エラーメッセージを確認
cat data/fanza/new_releases_$(date +%Y%m%d).json | jq '.result.message'
```

---

## 📚 関連コマンド

- `/daily-update` - 毎日の開発進捗レポート自動生成
- `/voicevox` - 音声合成による通知

---

## 🔄 定期実行設定（オプション）

### cron設定例（毎日12時に実行）

```bash
# crontab -e
0 12 * * * cd /Users/shunsuke/Dev/miyabi-private && source .env.fanza && ./tools/fanza_fetch_new_releases.sh 30 >> logs/fanza_cron.log 2>&1
```

### GitHub Actions設定例

```yaml
name: FANZA Daily Tracking

on:
  schedule:
    - cron: '0 12 * * *'  # 毎日12時（UTC）

jobs:
  track:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Fetch FANZA new releases
        env:
          DMM_API_ID: ${{ secrets.DMM_API_ID }}
          DMM_AFFILIATE_ID: ${{ secrets.DMM_AFFILIATE_ID }}
        run: |
          ./tools/fanza_fetch_new_releases.sh 30
      - name: Commit results
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add data/fanza/
          git commit -m "chore(fanza): daily tracking $(date +%Y-%m-%d)"
          git push
```

---

**作成日**: 2025-10-27
**バージョン**: v1.0.0
**カテゴリ**: data-collection, fanza, tracking
**タグ**: #fanza #dmm #api #tracking #daily
