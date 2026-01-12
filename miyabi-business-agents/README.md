# Miyabi Business Agents Plugin

**Version**: 2.0.0
**Category**: Business Automation
**License**: Apache-2.0

16のビジネス専門AIエージェントを提供する Claude Code プラグイン。市場分析、ペルソナ設計、コンテンツ制作、マーケティング、セールス、CRM、アナリティクスまで包括的なビジネス自動化を実現します。

## Installation

```bash
# マーケットプレイス追加
/plugin marketplace add customer-cloud/miyabi-private

# プラグインインストール
/plugin install miyabi-business-agents@miyabi-official-plugins

# Claude Code 再起動
```

## Agents Overview

### Business Agent一覧 (16個)

| Agent | キャラクター | 色 | 役割 | フェーズ |
|-------|------------|-----|------|---------|
| **AIEntrepreneurAgent** | あきんどさん 🏢 | 🔴 | リーダー | 全体統括 |
| **SelfAnalysisAgent** | じぶんさん 🪞 | 🔵 | 分析役 | Phase 1 |
| **MarketResearchAgent** | しらべるん 🔬 | 🔵 | 分析役 | Phase 2 |
| **PersonaAgent** | なりきりん 🎭 | 🔵 | 分析役 | Phase 3 |
| **ProductConceptAgent** | つくろん 💡 | 🟢 | 実行役 | Phase 4 |
| **ProductDesignAgent** | かくん 🎨 | 🟢 | 実行役 | Phase 5 |
| **ContentCreationAgent** | かくちゃん ✏️ | 🟢 | 実行役 | Phase 6 |
| **FunnelDesignAgent** | みちびきん 🛤️ | 🟢 | 実行役 | Phase 7 |
| **SNSStrategyAgent** | つぶやきん 📱 | 🟢 | 実行役 | Phase 8 |
| **MarketingAgent** | ひろめるん 📣 | 🟢 | 実行役 | Phase 9 |
| **SalesAgent** | うるん 🤝 | 🟢 | 実行役 | Phase 10 |
| **CRMAgent** | おきゃくさま 💚 | 🟢 | 実行役 | Phase 11 |
| **AnalyticsAgent** | かぞえるん 📊 | 🔵 | 分析役 | Phase 12 |
| **YouTubeAgent** | どうがん 🎬 | 🟢 | 実行役 | コンテンツ |
| **NoteAgent** | かきこちゃん 📝 | 🟢 | 実行役 | コンテンツ |
| **ImageGenAgent** | えがくん 🖼️ | 🟢 | 実行役 | コンテンツ |

---

## Phase-Based Business Workflow

```
┌─────────────────────────────────────────────────────────────────┐
│                 Miyabi Business Agent Workflow                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Phase 1-3: 分析フェーズ (🔵 Analysis)                           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │ SelfAnalysis│→│MarketResearch│→│  Persona   │               │
│  │ じぶんさん   │ │ しらべるん   │ │ なりきりん  │               │
│  │ SWOT分析   │ │ 競合20社分析 │ │ 3-5ペルソナ │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                  │
│  Phase 4-6: 設計フェーズ (🟢 Design)                             │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │ProductConcept│→│ProductDesign│→│ContentCreate│               │
│  │ つくろん     │ │  かくん     │ │ かくちゃん   │               │
│  │ USP・MVP    │ │ 6ヶ月計画   │ │ 動画・記事   │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                  │
│  Phase 7-9: 集客フェーズ (🟢 Acquisition)                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │FunnelDesign │→│ SNSStrategy │→│  Marketing  │               │
│  │ みちびきん   │ │ つぶやきん   │ │ ひろめるん   │               │
│  │ 導線設計    │ │ 投稿計画    │ │ 広告・SEO   │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                  │
│  Phase 10-12: 収益化フェーズ (🟢 Monetization)                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐               │
│  │   Sales     │→│    CRM      │→│  Analytics  │               │
│  │   うるん     │ │ おきゃくさま │ │ かぞえるん   │               │
│  │ セールス    │ │ LTV最大化   │ │ PDCA       │               │
│  └─────────────┘ └─────────────┘ └─────────────┘               │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## AIEntrepreneurAgent (あきんどさん)

**Role**: AI起業家支援 - 8フェーズビジネスプラン作成

### 8-Phase Business Planning Chain

1. **市場トレンド分析** - 市場機会の特定
2. **競合分析** - SWOT・差別化ポイント
3. **ターゲット顧客分析** - ペルソナ作成
4. **価値提案作成** - USP策定
5. **収益モデル設計** - 価格戦略・損益分岐
6. **マーケティング戦略** - チャネル・KPI
7. **チーム編成** - 組織設計
8. **資金調達計画** - 調達方法・タイムライン

### Usage

```bash
# Task tool経由
subagent_type: "AIEntrepreneurAgent"
prompt: "AIヘルスケア市場で起業するビジネスプランを作成してください"
```

### A2A Bridge Tools

```
a2a.ai_entrepreneur_support_and_business_planning_agent.create_business_plan
a2a.ai_entrepreneur_support_and_business_planning_agent.analyze_market
a2a.ai_entrepreneur_support_and_business_planning_agent.design_funding_plan
```

### Output Files

```
docs/business-plan/
├── 001-market-trend-report.md
├── 002-competitor-analysis.md
├── 003-customer-analysis.md
├── 004-value-proposition.md
├── 005-revenue-model.md
├── 006-marketing-strategy.md
├── 007-team-structure.md
├── 008-funding-plan.md
└── FINAL-BUSINESS-PLAN.md
```

---

## SelfAnalysisAgent (じぶんさん)

**Role**: Phase 1 - 自己分析・SWOT分析

### Capabilities

- **キャリア分析**: 経験・実績の棚卸し
- **スキルマッピング**: 技術・ビジネススキル
- **SWOT分析**: 強み・弱み・機会・脅威
- **差別化要因抽出**: ユニークな価値

### A2A Bridge Tools

```
a2a.self-analysis_and_business_strategy_planning_agent_with_swot_analysis.analyze_self
a2a.self-analysis_and_business_strategy_planning_agent_with_swot_analysis.generate_swot
a2a.self-analysis_and_business_strategy_planning_agent_with_swot_analysis.extract_skills
```

---

## MarketResearchAgent (しらべるん)

**Role**: Phase 2 - 市場調査・競合分析 (20社以上)

### Capabilities

- **市場規模推定**: TAM/SAM/SOM算出
- **トレンド分析**: 業界動向の把握
- **競合分析**: 20社以上の詳細分析
- **機会特定**: 参入ポイントの発見

### A2A Bridge Tools

```
a2a.market_research_and_competitive_analysis_agent.research_market
a2a.market_research_and_competitive_analysis_agent.analyze_competitors
a2a.market_research_and_competitive_analysis_agent.identify_opportunities
```

---

## PersonaAgent (なりきりん)

**Role**: Phase 3 - ペルソナ設計 (3-5人)

### Capabilities

- **ペルソナ作成**: 詳細な顧客像 3-5人
- **カスタマージャーニー**: 認知→購入→LTV
- **ペインポイント特定**: 課題・ニーズ
- **購買心理分析**: 意思決定要因

### A2A Bridge Tools

```
a2a.persona_and_customer_segment_analysis_agent.analyze_personas
a2a.persona_and_customer_segment_analysis_agent.create_journey_map
a2a.persona_and_customer_segment_analysis_agent.identify_pain_points
```

---

## ProductConceptAgent (つくろん)

**Role**: Phase 4 - USP・収益モデル・ビジネスモデルキャンバス

### Capabilities

- **USP策定**: ユニークセリングポイント
- **収益モデル設計**: サブスク/従量/広告等
- **ビジネスモデルキャンバス**: 9要素設計
- **MVP定義**: 最小限の実行可能製品

### A2A Bridge Tools

```
a2a.product_concept_and_business_model_design_agent.design_concept
a2a.product_concept_and_business_model_design_agent.design_business_model
a2a.product_concept_and_business_model_design_agent.define_mvp
```

---

## ProductDesignAgent (かくん)

**Role**: Phase 5 - 6ヶ月コンテンツ・技術スタック・MVP定義

### Capabilities

- **コンテンツ計画**: 6ヶ月分のコンテンツ
- **技術スタック選定**: フロント/バック/インフラ
- **MVP設計**: 機能優先度・ロードマップ
- **UI/UXガイドライン**: デザインシステム

### A2A Bridge Tools

```
a2a.product_design_and_service_specification_agent.design_service
a2a.product_design_and_service_specification_agent.create_content_plan
a2a.product_design_and_service_specification_agent.define_tech_stack
```

---

## ContentCreationAgent (かくちゃん)

**Role**: Phase 6 - 動画・記事・教材等の実コンテンツ制作計画

### Capabilities

- **動画企画**: YouTube/Udemy向け
- **記事制作**: ブログ/note/SEO記事
- **教材作成**: オンラインコース設計
- **配信計画**: 投稿スケジュール

### A2A Bridge Tools

```
a2a.content_creation_and_production_agent.create_content
a2a.content_creation_and_production_agent.plan_production
a2a.content_creation_and_production_agent.optimize_distribution
```

---

## FunnelDesignAgent (みちびきん)

**Role**: Phase 7 - 認知→購入→LTVまでの顧客導線最適化

### Capabilities

- **ファネル設計**: AARRR/TOFU-MOFU-BOFU
- **タッチポイント最適化**: 各接点の改善
- **コンバージョン設計**: CVR向上施策
- **リテンション**: LTV最大化

### A2A Bridge Tools

```
a2a.customer_funnel_design_agent.design_funnel
a2a.customer_funnel_design_agent.optimize_touchpoints
a2a.customer_funnel_design_agent.calculate_conversion
```

---

## SNSStrategyAgent (つぶやきん)

**Role**: Phase 8 - Twitter/Instagram/YouTube等のSNS戦略立案

### Capabilities

- **プラットフォーム選定**: 最適SNS特定
- **投稿カレンダー作成**: 月間投稿計画
- **エンゲージメント戦略**: いいね/コメント/シェア
- **インフルエンサー連携**: コラボ戦略

### A2A Bridge Tools

```
a2a.sns_strategy_and_content_planning_agent.plan_strategy
a2a.sns_strategy_and_content_planning_agent.create_calendar
a2a.sns_strategy_and_content_planning_agent.analyze_engagement
```

---

## MarketingAgent (ひろめるん)

**Role**: Phase 9 - 広告・SEO・SNS等を駆使した集客施策実行計画

### Capabilities

- **広告戦略**: Google/Meta/Twitter Ads
- **SEO最適化**: キーワード・コンテンツ戦略
- **メールマーケティング**: リスト構築・ナーチャリング
- **予算配分**: ROAS最適化

### A2A Bridge Tools

```
a2a.marketing_strategy_and_execution_agent.execute_marketing
a2a.marketing_strategy_and_execution_agent.plan_ads
a2a.marketing_strategy_and_execution_agent.optimize_seo
```

---

## SalesAgent (うるん)

**Role**: Phase 10 - リード→顧客の転換率最大化とセールスプロセス最適化

### Capabilities

- **セールスプロセス設計**: SDR/BDR/AE体制
- **リード管理**: MQL/SQL基準
- **パイプライン管理**: 案件追跡
- **クロージング**: 提案・交渉・契約

### A2A Bridge Tools

```
a2a.sales_process_optimization_agent.optimize_sales
a2a.sales_process_optimization_agent.manage_leads
a2a.sales_process_optimization_agent.create_pipeline
```

---

## CRMAgent (おきゃくさま)

**Role**: Phase 11 - 顧客満足度向上とLTV最大化のための顧客管理体制構築

### Capabilities

- **顧客管理**: CRMシステム設計
- **LTV最大化**: アップセル/クロスセル
- **チャーン防止**: 解約予兆検知
- **NPS管理**: 顧客満足度測定

### A2A Bridge Tools

```
a2a.customer_relationship_management_agent.manage_customers
a2a.customer_relationship_management_agent.maximize_ltv
a2a.customer_relationship_management_agent.reduce_churn
```

---

## AnalyticsAgent (かぞえるん)

**Role**: Phase 12 - 全データ分析・PDCAサイクル実行・継続的改善

### Capabilities

- **KPIダッシュボード**: リアルタイム監視
- **データ分析**: 行動分析・コホート分析
- **レポート生成**: 週次/月次レポート
- **PDCA実行**: 改善提案・A/Bテスト

### A2A Bridge Tools

```
a2a.data_analytics_and_business_intelligence_agent.analyze_data
a2a.data_analytics_and_business_intelligence_agent.generate_report
a2a.data_analytics_and_business_intelligence_agent.track_kpi
```

---

## YouTubeAgent (どうがん)

**Role**: YouTube運用最適化 - 13ワークフロー完備

### 13 Workflows

1. チャンネル設計
2. サムネイル設計
3. タイトル最適化
4. 説明文作成
5. タグ戦略
6. 投稿スケジュール
7. コミュニティ運営
8. ショート動画戦略
9. 収益化設計
10. アナリティクス分析
11. 競合チャンネル分析
12. コラボ戦略
13. 広告戦略

### A2A Bridge Tools

```
a2a.youtube_channel_optimization_agent.optimize_channel
a2a.youtube_channel_optimization_agent.plan_content
a2a.youtube_channel_optimization_agent.write_script
```

---

## NoteAgent (かきこちゃん)

**Role**: note.com記事執筆 - 感情設計重視のバズるコンテンツ自動生成

### Capabilities

- **記事構成**: 感情曲線設計
- **タイトル生成**: クリック率最適化
- **本文執筆**: ストーリーテリング
- **CTA設計**: 行動喚起最適化

---

## ImageGenAgent (えがくん)

**Role**: note.com記事やSNS投稿用の画像生成専門スタッフ

### Capabilities

- **サムネイル生成**: YouTube/note用
- **SNS画像**: Instagram/Twitter用
- **バナー作成**: 広告・LP用
- **図解**: 概念図・フロー図

---

## Special Agents

### JonathanIveDesignAgent (いぶさん)

UI/UXを極限まで洗練させるデザイナー。ジョナサン・アイブの哲学でミニマリズムを実現。

### HonokaAgent (ほのかちゃん)

オンラインコース作成 & コンテンツ販売の専門家。13ステップのUdemyコース設計。

---

## Configuration

### Agent設定ファイル

```
.claude/agents/specs/business/
├── ai-entrepreneur-agent.md
├── self-analysis-agent.md
├── market-research-agent.md
├── persona-agent.md
├── product-concept-agent.md
├── product-design-agent.md
├── content-creation-agent.md
├── funnel-design-agent.md
├── sns-strategy-agent.md
├── marketing-agent.md
├── sales-agent.md
├── crm-agent.md
├── analytics-agent.md
├── youtube-agent.md
├── note-agent.md
└── imagegen-agent.md
```

---

## Metrics

| Metric | Target |
|--------|--------|
| 実行時間 | 15-25分（全フェーズ） |
| 生成ドキュメント | 8-10ファイル |
| 総文字数 | 20,000-40,000文字 |
| 成功率 | 90%+ |

---

## Related Plugins

- [miyabi-coding-agents](../miyabi-coding-agents/) - コーディング自動化
- [miyabi-honoka](../miyabi-honoka/) - Udemyコース作成特化

---

**Author**: Shunsuke Hayashi
**Created**: 2025-11-29
**Version**: 2.0.0
