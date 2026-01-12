# /generate-lp - ランディングページ自動生成

**Agent**: LPGenAgent（つくるんLP）

## 概要

参考URLを受け取り、そのデザインを分析して、ユーザーのコンテンツに合わせた高品質なランディングページを自動生成します。

## 使用方法

```bash
/generate-lp <参考URL>
```

### 引数

- `<参考URL>`: デザインの参考にしたいランディングページのURL（必須）

### 例

```bash
/generate-lp https://happytry-lp.site?vos=meta
/generate-lp https://www.apple.com/iphone/
/generate-lp https://stripe.com/
```

## 実行フロー

このコマンドを実行すると、以下の流れで処理されます：

### Step 1: 参考サイト分析

LPGenAgentが参考URLを分析し、以下の情報を抽出します：

- ✅ セクション構成（ヒーロー、特徴、料金、FAQ等）
- ✅ 色彩体系（プライマリ、アクセント、背景）
- ✅ レイアウトパターン（グリッド、フレックス）
- ✅ レスポンシブ対応（ブレークポイント）
- ✅ 視覚要素（ボタン、タイポグラフィ）

### Step 2: 情報収集（4問）

以下の質問に回答してください：

1. **サービス種別**: SaaS、コンサルティング、ECサイト、カスタム
2. **アクセントカラー**: 青系、緑系、紫系、オレンジ系
3. **CTA種別**: 無料トライアル、資料DL、問い合わせ、デモ予約（複数選択可）
4. **基本情報**: サービス名、ターゲット、キャッチコピー、価値提案3つ

### Step 3: HTML生成

TailwindCSS v3.4を使った完全なランディングページを生成：

- ✅ レスポンシブ対応（Mobile-First）
- ✅ SEO最適化（meta tags、Open Graph、Twitter Card）
- ✅ アクセシビリティ対応（ARIA属性）
- ✅ アニメーション対応（Alpine.js）
- ✅ 9つのセクション（ヘッダー、ヒーロー、特徴、料金、FAQ、CTA、フッター等）

### Step 4: ドキュメント生成

以下のファイルが生成されます：

```
生成ディレクトリ/
├── index.html              # メインHTMLファイル（15KB程度）
├── design-analysis.json    # デザイン分析結果（2KB程度）
└── README.md              # カスタマイズガイド（3KB程度）
```

## 生成例

### 入力

```bash
/generate-lp https://happytry-lp.site?vos=meta
```

**質問への回答**:
- サービス種別: SaaS/Webサービス
- アクセントカラー: 緑系（成長・安心）
- CTA種別: 無料トライアル、資料ダウンロード
- サービス名: Miyabi
- ターゲット: エンジニア、開発チーム
- キャッチコピー: AIで開発を完全自動化
- 価値提案:
  1. Issue作成からデプロイまで自動化
  2. 50%以上の開発時間削減
  3. 並列実行で複数タスク同時処理

### 出力

```
✅ ランディングページ生成完了！

📁 生成ファイル:
- index.html (15KB)
- design-analysis.json (2KB)
- README.md (3KB)

🎨 デザイン情報:
- プライマリカラー: #10b981（緑系）
- セクション数: 9個
- CTA数: 3箇所

📋 次のステップ:
1. index.htmlをブラウザで開いてプレビュー: open index.html
2. コンテンツ・画像をカスタマイズ（README.md参照）
3. GitHub Pages / Vercel / Netlifyにデプロイ

💡 カスタマイズガイド: README.mdを参照
```

## カスタマイズ方法

生成後、`README.md`に詳細なカスタマイズガイドが含まれています：

- **カラー変更**: TailwindCSSクラスの置換
- **コンテンツ変更**: キャッチコピー、価値提案、料金、FAQ
- **画像差し替え**: プレースホルダーを実際の画像に置換
- **デプロイ方法**: GitHub Pages、Vercel、Netlify

## デプロイ方法

### 1. GitHub Pages（無料）

```bash
# 生成されたディレクトリに移動
cd [生成ディレクトリ]

# Gitリポジトリ初期化
git init
git add .
git commit -m "Initial commit: Landing page by LPGenAgent"

# GitHubリポジトリに接続
git remote add origin https://github.com/[ユーザー名]/[リポジトリ名].git
git push -u origin main

# Settings → Pages → Source: main branch
# 数分後、https://[ユーザー名].github.io/[リポジトリ名]/ で公開
```

### 2. Vercel（無料）

```bash
# Vercel CLIインストール
npm i -g vercel

# 生成されたディレクトリに移動
cd [生成ディレクトリ]

# デプロイ
vercel deploy

# プロダクションデプロイ
vercel --prod
```

### 3. Netlify（無料）

```bash
# Netlify CLIインストール
npm i -g netlify-cli

# 生成されたディレクトリに移動
cd [生成ディレクトリ]

# デプロイ
netlify deploy

# プロダクションデプロイ
netlify deploy --prod
```

## トラブルシューティング

### Q: 参考URLからデザインを取得できない

**A**: デフォルトデザインパターン（青系、Z型レイアウト）を使用します。続行しますか？

### Q: 画像が表示されない

**A**: プレースホルダー画像を使用しています。実際の画像に置換してください：

```html
<!-- Before -->
<img src="https://placehold.co/600x400" alt="...">

<!-- After -->
<img src="./images/hero.jpg" alt="...">
```

### Q: カラーを変更したい

**A**: `index.html`内の以下のクラスを検索・置換：

```
緑系 → 青系:
bg-green-500 → bg-blue-600
text-green-500 → text-blue-600
```

### Q: セクションを追加・削除したい

**A**: `README.md`の「カスタマイズ方法」セクションを参照してください。

## 品質保証

生成されるランディングページは以下の品質基準を満たします：

### パフォーマンス

- ✅ Lighthouse Performance Score: 90+
- ✅ First Contentful Paint: < 1.5s
- ✅ Largest Contentful Paint: < 2.5s

### アクセシビリティ

- ✅ WCAG 2.1 Level A準拠
- ✅ キーボードナビゲーション対応
- ✅ スクリーンリーダー対応
- ✅ カラーコントラスト比: 4.5:1以上

### SEO

- ✅ セマンティックHTML5使用
- ✅ meta description（155文字以内）
- ✅ Open Graph tags完備
- ✅ Twitter Card tags完備

### レスポンシブ

- ✅ Mobile（320px～）
- ✅ Tablet（768px～）
- ✅ Desktop（1024px～）

## 技術スタック

生成されるランディングページは以下の技術を使用：

- **HTML5**: セマンティックマークアップ
- **TailwindCSS v3.4**: ユーティリティファーストCSS（CDN）
- **Alpine.js v3**: 軽量JavaScriptフレームワーク（CDN）
- **Google Fonts**: Inter（タイポグラフィ）

## 注意事項

1. **画像プレースホルダー**: 実際の画像に置換してください
2. **フォーム送信機能なし**: バックエンド連携は別途実装必要
3. **TailwindCSS CDN**: プロダクションではビルドプロセス推奨
4. **ブラウザ対応**: モダンブラウザ（Chrome, Firefox, Safari, Edge最新版）

## 関連ドキュメント

- **Agent仕様書**: `.claude/agents/specs/business/lp-gen-agent.md`
- **実行プロンプト**: `.claude/agents/prompts/business/lp-gen-agent-prompt.md`
- **キャラクター図鑑**: `.claude/agents/AGENT_CHARACTERS.md`

---

**Agent**: LPGenAgent v1.0.0
**最終更新**: 2025-10-22
