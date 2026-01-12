---
name: SlideGenAgent
description: Slide Generation Agent
type: agent
subagent_type: "SlideGenAgent"
---

# SlideGenAgent仕様書

**バージョン**: v1.0.0
**ステータス**: 📋 Planning (実装予定)
**Target Release**: v1.3.0
**最終更新**: 2025-10-22
**カテゴリ**: Business Agent（15個目）
**キャラクター名**: すらいだー（Slider）

---

## 🎯 Agent概要

**SlideGenAgent** は、AI駆動でプレゼンテーションスライドを自動生成するビジネスエージェントです。GitHub全体検索で調査したPPTAgent（EMNLP 2025）、presentation-ai、ChatPPTの知見を統合し、Miyabiエコシステムに最適化された設計となっています。

### 位置づけ

- **Business Agents**: 15個目（AIEntrepreneur〜AnalyticsAgentに続く）
- **色分け**: 🟢 実行役（並列実行可能）
- **並列実行**: ✅ 他のBusiness Agentと同時実行可能

---

## 📋 責任と権限

### 主要責任

1. **Outline-Driven Generation**: アウトライン駆動のスライド生成ワークフロー
2. **Multi-Model Orchestration**: 複数AIモデル（テキスト生成・画像生成）の統合
3. **Theme Customization**: 4種類のテーマ（Apple, Classic, Dark, Modern）のサポート
4. **Quality Evaluation**: PPTEvalフレームワークによる品質評価（Content, Design, Coherence）
5. **Export Formats**: Reveal.js HTML、PDF、.pptxへのエクスポート

### 権限レベル

- **ファイル作成**: HTML/CSS/JSファイルの生成
- **API呼び出し**: BytePlus ARK API（Text-to-Image, Chat Completion）
- **GitHub連携**: Project V2へのスライド品質データ登録
- **外部サービス**: Reveal.js CDN、Google Fonts、FontAwesome

### エスカレーション条件

以下の状況では、CoordinatorAgentまたはユーザーへエスカレーション：

1. **API制限到達**: BytePlus ARK API rate limit超過
2. **品質スコア低下**: 全体品質スコアが60点未満
3. **テーマ互換性問題**: カスタムテーマがReveal.jsと競合
4. **画像生成失敗**: 連続3回以上の画像生成エラー
5. **依存関係エラー**: Reveal.js CDNアクセス不可

---

## 🔄 ワークフロー

### 3-Phase Generation Process

SlideGenAgentは、presentation-aiのOutline Phase + PPTAgentのAnalysis/Generationを統合した3段階プロセスを採用：

#### Phase 1: Analysis & Outline
**Input**: プレゼンテーショントピック、対象オーディエンス、スライド数、スタイル
**Process**:
1. トピック分析（キーワード抽出、構造化）
2. アウトライン生成（セクション構成、スライドタイプ決定）
3. ユーザー承認（編集可能なJSON/YAMLアウトライン）

**Output**: 構造化アウトライン（JSON）
```json
{
  "title": "Miyabi - 完全自律型AI開発OS",
  "sections": [
    {
      "title": "はじめに",
      "slides": [
        { "type": "title", "content": "タイトルスライド" },
        { "type": "intro", "content": "自己紹介" }
      ]
    },
    {
      "title": "問題提起",
      "slides": [
        { "type": "problem", "content": "現状の課題" },
        { "type": "statistics", "content": "データで見る問題" }
      ]
    }
  ]
}
```

#### Phase 2: Generation & Design
**Input**: 承認されたアウトライン、選択されたテーマ
**Process**:
1. スライド生成（テキストコンテンツ）
   - BytePlus ARK Chat Completionでコンテンツ生成
   - Reveal.js HTMLテンプレートへの埋め込み
2. 画像生成（視覚要素）
   - BytePlus ARK T2I APIで画像生成
   - プロンプト最適化（スライドタイプごと）
3. テーマ適用
   - 選択されたCSS（Apple/Classic/Dark/Modern）適用
   - カスタムテーマのバリデーション

**Output**: 完全なReveal.js HTMLプレゼンテーション

#### Phase 3: Evaluation & Export
**Input**: 生成されたスライド
**Process**:
1. 品質評価（PPTEval Framework）
   - Content Score: テキスト長、構造、可読性
   - Design Score: 視覚要素、バランス、美観
   - Coherence Score: 論理的フロー、前後スライドの繋がり
2. 改善提案生成
   - 低品質スライド（60点未満）の特定
   - 改善アクションの提案
3. エクスポート
   - Reveal.js HTML（プライマリ）
   - PDF（Reveal.js PDF export）
   - .pptx（python-pptx統合、オプション）

**Output**: 品質レポート + エクスポートファイル

---

## 🎨 Theme System

### 4つのビルトインテーマ

| テーマ | スタイル | ユースケース | CSS | Reveal.js Theme |
|--------|---------|-------------|-----|-----------------|
| **Apple** | ミニマル、白ベース、Apple風 | 企業プレゼン、製品発表 | `styles-apple.css` | white |
| **Classic** | 伝統的、ビジネス、保守的 | ビジネス報告、学会発表 | `styles-classic.css` | simple |
| **Dark** | ダークモード、ハイコントラスト | 技術カンファレンス、夜間プレゼン | `styles-dark.css` | black |
| **Modern** | グラデーション、ガラスモーフィズム | デザイン系、クリエイティブプレゼン | `styles-v2.css` | black |

### カスタムテーマ作成

ユーザーは独自のテーマを作成可能：
1. CSSファイル作成（`styles-custom.css`）
2. `AVAILABLE_THEMES`オブジェクトに登録（script.js）
3. ローカルストレージに保存

---

## 🤖 AI Model Orchestration

### 使用AIモデル

#### Text Generation
- **Primary**: BytePlus ARK Chat Completion
- **Model**: `ep-20250315091006-vg89g`（Claude Sonnet 4相当）
- **Fallback**: OpenAI GPT-4（オプション）

#### Image Generation
- **Primary**: BytePlus ARK T2I
- **Model**: `seedream-4-0-250828`
- **Fallback**: DALL-E 3、Stable Diffusion（オプション）

### プロンプト最適化

スライドタイプごとに最適化されたプロンプトテンプレート：

| Slide Type | Text Prompt Template | Image Prompt Template |
|------------|---------------------|---------------------|
| `title` | "Create a compelling title slide for {topic}" | "Professional title slide background, {theme} style" |
| `intro` | "Write a 2-3 sentence introduction for {presenter}" | "Professional portrait, {presenter_description}" |
| `problem` | "Describe the problem: {problem_statement}" | "Visual metaphor for {problem}, abstract style" |
| `solution` | "Explain the solution: {solution_description}" | "Solution diagram, {tech_stack} architecture" |
| `demo` | "Demo instructions: {demo_steps}" | "Screenshot of {product} interface, clean UI" |
| `statistics` | "Present these statistics: {data}" | "Data visualization, bar chart, {data_theme}" |

---

## 📊 Quality Evaluation (PPTEval Framework)

### 評価基準

#### Content Score (0-100)
- ✅ テキスト長（50-500文字: +30点）
- ✅ 見出し構造（H1/H2: +25点）
- ✅ リスト構造（UL/OL: +20点）
- ✅ 段落数（1-3個: +15点）
- ✅ コードスニペット（+10点ボーナス）

#### Design Score (0-100)
- ✅ 視覚要素（画像/SVG: +20点）
- ✅ コードブロック（+10点）
- ✅ アニメーション（+10点）
- ✅ アイコン（+10点）
- ✅ カスタム背景（+10点）
- ✅ 可読性（+10点）
- ✅ ベーススコア（+40点）

#### Coherence Score (0-100)
- ✅ 前後スライドの論理的つながり
- ✅ トピックの一貫性
- ✅ 構造的フロー
- ✅ 特別ボーナス（タイトルスライド: +20点、最終スライド: +20点）

### 品質グレード

| Score | Grade | 評価 |
|-------|-------|------|
| 95-100 | A+ | Excellent（優秀） |
| 90-94 | A | Excellent（優秀） |
| 85-89 | B+ | Good（良好） |
| 80-84 | B | Good（良好） |
| 75-79 | C+ | Acceptable（許容） |
| 70-74 | C | Acceptable（許容） |
| 60-69 | D | Needs Improvement（要改善） |
| 0-59 | F | Poor（不良） |

---

## 🔌 API統合

### BytePlus ARK API

#### Chat Completion
```bash
curl -X POST https://ark.ap-southeast.bytepluses.com/api/v3/chat/completions \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "ep-20250315091006-vg89g",
    "messages": [{"role": "user", "content": "Create slide content..."}]
  }'
```

#### Text-to-Image
```bash
curl -X POST https://ark.ap-southeast.bytepluses.com/api/v3/images/generations \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "seedream-4-0-250828",
    "prompt": "Professional slide background...",
    "size": "1920x1080",
    "response_format": "b64_json"
  }'
```

### GitHub API（オプション）

品質データをProject V2に登録：
```bash
gh api graphql -f query='
  mutation {
    addProjectV2ItemById(input: {
      projectId: "PROJECT_ID"
      contentId: "ISSUE_ID"
    }) {
      item { id }
    }
  }
'
```

---

## 🛠️ 技術スタック

### Frontend
- **Reveal.js 4.5.0**: HTMLプレゼンテーションフレームワーク
- **AOS.js**: スクロールアニメーション
- **FontAwesome 6.4.0**: アイコンライブラリ
- **Google Fonts**: Inter, Merriweather

### Backend（Rust実装予定）
- **crates/miyabi-business-agents/src/slide_gen.rs**: コアロジック
- **miyabi-types**: 型定義（SlideOutline, SlideContent, QualityReport）
- **reqwest**: HTTP client（BytePlus ARK API）
- **serde_json**: JSON処理
- **tokio**: 非同期ランタイム

### Dependencies
```toml
[dependencies]
miyabi-types = { path = "../miyabi-types" }
reqwest = { version = "0.11", features = ["json"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.0", features = ["full"] }
anyhow = "1.0"
base64 = "0.21"
```

---

## 📁 ファイル構造

```
.claude/agents/
├── specs/business/
│   └── slide-gen-agent.md              # 本ファイル（仕様書）
├── prompts/business/
│   └── slide-gen-agent-prompt.md       # Agent実行プロンプト
└── README.md                            # Agentディレクトリ概要

crates/miyabi-business-agents/
├── src/
│   ├── slide_gen.rs                    # SlideGenAgent実装
│   ├── lib.rs                          # エントリーポイント
│   └── types/
│       ├── slide_outline.rs            # アウトライン型定義
│       ├── slide_content.rs            # コンテンツ型定義
│       └── quality_report.rs           # 品質レポート型定義
└── Cargo.toml                          # 依存関係

docs/conferences/slides/
├── index.html                          # 生成されたスライド
├── styles-apple.css                    # Appleテーマ
├── styles-classic.css                  # Classicテーマ
├── styles-dark.css                     # Darkテーマ
├── styles-v2.css                       # Modernテーマ
├── script.js                           # インタラクティブスクリプト
│                                       # - Theme Customization System
│                                       # - Slide Quality Evaluation System
└── AI_PRESENTATION_RESEARCH.md         # GitHub調査レポート
```

---

## 🚀 使用例

### CLI実行

```bash
# SlideGenAgent実行（アウトライン生成）
miyabi agent run slide-gen --topic "Miyabi紹介" --slides 30 --theme apple

# 既存アウトラインから生成
miyabi agent run slide-gen --outline outline.json --theme dark

# 品質評価のみ
miyabi agent run slide-gen --evaluate slides/index.html
```

### Rust API

```rust
use miyabi_business_agents::SlideGenAgent;
use miyabi_types::{SlideOutline, SlideConfig};

#[tokio::main]
async fn main() -> Result<()> {
    let config = SlideConfig {
        topic: "Miyabi - 完全自律型AI開発OS".to_string(),
        slide_count: 30,
        theme: "apple".to_string(),
        audience: "技術カンファレンス".to_string(),
    };

    let agent = SlideGenAgent::new(config);

    // Phase 1: Outline生成
    let outline = agent.generate_outline().await?;
    println!("Outline: {:#?}", outline);

    // Phase 2: スライド生成
    let slides = agent.generate_slides(&outline).await?;
    agent.save_html("output/index.html", &slides).await?;

    // Phase 3: 品質評価
    let quality = agent.evaluate_quality(&slides).await?;
    println!("Quality Report: {:#?}", quality);

    Ok(())
}
```

### JavaScript API（Reveal.js統合）

```javascript
// テーマ切り替え
MiyabiPresentation.switchTheme('dark');

// 品質評価
const quality = MiyabiPresentation.getAverageQuality();
console.log(`Overall Quality: ${quality.average}/100 (${quality.grade})`);

// スライド評価（個別）
const slide5 = MiyabiPresentation.evaluateSlideQuality(5);
console.log(`Slide 5: ${slide5.overall}/100`);
```

---

## 🔄 既存Agentとの連携

### Business Agent Pipeline

```
AIEntrepreneurAgent（ビジネスプラン）
  ↓
ProductConceptAgent（製品コンセプト）
  ↓
SlideGenAgent（プレゼン資料生成）← NEW!
  ↓
MarketingAgent（プロモーション資料）
```

### Coding Agent Pipeline

```
IssueAgent（Issue分析）
  ↓
CoordinatorAgent（タスク分解）
  ↓
SlideGenAgent（技術資料生成）← オプション
  ↓
PRAgent（ドキュメント追加PR）
```

---

## 📈 KPI・成功指標

### 生成品質

- **目標**: 全スライドの平均品質スコア80点以上
- **測定**: PPTEvalフレームワークによる自動評価
- **改善**: 低品質スライド（60点未満）の自動再生成

### 生成速度

- **目標**: 30スライドを5分以内に生成
- **測定**: Phase 1-3の合計実行時間
- **最適化**: バッチ処理、キャッシング、並列API呼び出し

### API使用効率

- **目標**: 画像生成失敗率5%以下
- **測定**: 画像生成API成功率
- **フォールバック**: Dall-E 3、Stable Diffusionへの自動切り替え

### ユーザー満足度

- **目標**: 生成スライドの手動修正率30%以下
- **測定**: ユーザーが直接編集したスライド数/全スライド数
- **改善**: ユーザーフィードバック収集、プロンプト改善

---

## 🧪 テスト戦略

### 単体テスト（Rust）

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_generate_outline() {
        let agent = SlideGenAgent::new(test_config());
        let outline = agent.generate_outline().await.unwrap();
        assert_eq!(outline.sections.len(), 5);
    }

    #[tokio::test]
    async fn test_evaluate_quality() {
        let slide = test_slide_html();
        let quality = evaluate_slide_quality(&slide);
        assert!(quality.overall >= 60);
    }
}
```

### 統合テスト（E2E）

```bash
# 完全なスライド生成フロー
cargo test --test integration_slide_gen -- --nocapture

# 品質評価テスト
cargo test --test quality_evaluation -- --nocapture
```

### 手動テスト

1. **テーマ切り替え**: 4テーマすべてで正常レンダリング確認
2. **品質評価**: 各スライドの品質スコアが妥当か確認
3. **画像生成**: 生成画像がスライドテーマに合致するか確認
4. **エクスポート**: PDF/PPTXエクスポートが正常に動作するか確認

---

## 🐛 トラブルシューティング

### 問題1: 画像生成が失敗する

**症状**: BytePlus ARK APIから500エラー
**原因**: プロンプトが長すぎる、または不適切なパラメータ
**解決策**:
1. プロンプトを80文字以内に短縮
2. `size`パラメータを`1920x1080`に固定
3. Fallback（Dall-E 3）への自動切り替え

### 問題2: テーマが適用されない

**症状**: スライドのスタイルが変わらない
**原因**: CSSファイルパスが間違っている
**解決策**:
1. `script.js`の`AVAILABLE_THEMES`を確認
2. CSSファイルが正しいパスに存在するか確認
3. ブラウザのキャッシュをクリア

### 問題3: 品質スコアが低すぎる

**症状**: 全スライドのスコアが60点未満
**原因**: コンテンツが不足、または構造化されていない
**解決策**:
1. アウトライン再生成（より詳細な指示）
2. スライドタイプを変更（`problem` → `statistics`等）
3. 手動でコンテンツ追加後、再評価

### 問題4: Reveal.jsが動作しない

**症状**: スライドが表示されない、または操作できない
**原因**: CDNアクセス不可、またはJavaScriptエラー
**解決策**:
1. ブラウザのコンソールでエラー確認
2. Reveal.js CDNが正常にロードされているか確認
3. ローカルのReveal.jsバンドルを使用

---

## 🔮 今後の拡張計画

### Phase 1（v1.1.0）: Outline Editor UI
- Webベースのアウトライン編集UI
- ドラッグ&ドロップでスライド並び替え
- リアルタイムプレビュー

### Phase 2（v1.2.0）: Advanced AI Integration
- GPT-4 Vision APIで既存スライド分析
- Claudeによるスライド改善提案
- 音声生成（TTS）でナレーション追加

### Phase 3（v1.3.0）: Collaborative Editing
- 複数ユーザーでのリアルタイム共同編集
- コメント機能
- バージョン管理（Git統合）

### Phase 4（v1.4.0）: Analytics Dashboard
- スライド閲覧統計
- ヒートマップ（どのスライドが最も見られたか）
- A/Bテスト（複数バージョンのスライド比較）

---

## 📚 参考文献

### GitHub調査（2025-10-22）

1. **PPTAgent (EMNLP 2025)**
   - Repository: https://github.com/icip-cas/PPTAgent
   - 学習内容: Two-Phase Approach, PPTEval Framework

2. **presentation-ai (Gamma Alternative)**
   - Repository: https://github.com/allweonedev/presentation-ai
   - 学習内容: Outline Phase, Theme Customization, Component-Based Architecture

3. **ChatPPT (Multi-Model)**
   - Repository: https://github.com/Jayden-Cho/ChatPPT
   - 学習内容: Multiple AI Models Orchestration, Interactive Workflow

### 内部ドキュメント

- [AI_PRESENTATION_RESEARCH.md](../../../docs/conferences/slides/AI_PRESENTATION_RESEARCH.md)
- [ENTITY_RELATION_MODEL.md](../../../docs/ENTITY_RELATION_MODEL.md)
- [AGENT_OPERATIONS_MANUAL.md](../../../docs/AGENT_OPERATIONS_MANUAL.md)

---

## ✅ チェックリスト

### 実装前

- [x] GitHub全体検索で参考実装調査
- [x] PPTAgent、presentation-ai、ChatPPT分析
- [x] Theme Customization System実装
- [x] Slide Quality Evaluation System実装
- [ ] Agent仕様書作成（本ファイル）
- [ ] Agent実行プロンプト作成

### 実装中

- [ ] Rust型定義（SlideOutline, SlideContent, QualityReport）
- [ ] BytePlus ARK API統合
- [ ] アウトライン生成ロジック
- [ ] スライド生成ロジック
- [ ] 品質評価ロジック
- [ ] エクスポート機能（HTML, PDF, PPTX）

### 実装後

- [ ] 単体テスト作成
- [ ] 統合テスト作成
- [ ] ドキュメント更新（README.md）
- [ ] Business Agent一覧に追加
- [ ] キャラクター図鑑に「すらいだー」追加
- [ ] CLIコマンド統合

---

**作成者**: Claude Code
**レビュー**: Pending
**承認**: Pending
**次のアクション**: Agent実行プロンプト作成（`.claude/agents/prompts/business/slide-gen-agent-prompt.md`）
