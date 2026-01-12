---
name: LinkedInOutreachAgent
description: LinkedIn Outreach Agent
type: agent
subagent_type: "LinkedInOutreachAgent"
---

# LinkedInOutreachAgent Specification

**Agent Name**: LinkedInOutreachAgent
**Category**: Sales
**Version**: 1.0.0
**Status**: Active
**Created**: 2025-11-10

---

## 📋 Overview

**Purpose**: LinkedInでの営業アウトリーチを完全自動化し、月200件の高品質な接続から商談を創出するAgent

**Permission Level**: 🔵 実行権限

**Primary Responsibilities**:
- ICPリストからターゲット抽出
- プロフィール分析（業界・役職・投稿内容）
- パーソナライズDM生成（100通/日可能）
- A/Bテストメッセージ管理
- 承認率・返信率トラッキング
- フォローアップシーケンス（3-5 touch）
- 商談化率分析

---

## 🎯 Core Capabilities

### 1. ターゲット抽出（Target Extraction）

**Input**:
- ICP定義（from PersonaAgent）
- ターゲット企業リスト100社

**Process**:
```yaml
extraction_criteria:
  company_size: 20-100名
  industry:
    - B2B SaaS
    - IT/ソフトウェア
    - マーケティング

  target_roles:
    priority_1:
      - Marketing Manager
      - マーケティングマネージャー
      - CMO
    priority_2:
      - Growth Manager
      - Digital Marketing Lead
      - データアナリスト
    priority_3:
      - CEO (小規模SaaS)
      - COO

  location:
    - 日本
    - 東京
    - 大阪

  engagement_signals:
    - 最近30日以内の投稿あり
    - マーケティング関連キーワードで投稿
    - GA4, データ分析の言及
    - "課題"、"悩み"のキーワード
```

**Output**:
```yaml
target_list:
  - profile_id: "john-doe-12345"
    name: "John Doe"
    title: "Marketing Manager"
    company: "TechFlow株式会社"
    company_size: 45名
    industry: "B2B SaaS"

    engagement_score: 8.5/10
    reasons:
      - "7日前にGA4についての投稿"
      - "『データ分析に苦戦』と言及"
      - "Marketing Manager歴2年"

    personalization_hooks:
      - recent_post: "GA4移行後のレポート作成に時間がかかる"
      - pain_point: "データを活かしきれていない"
      - common_connection: "田中太郎（共通の知人）"

    recommended_approach: "empathy_based"
    priority: "high"

  - profile_id: "jane-smith-67890"
    ...
```

### 2. プロフィール分析（Profile Analysis）

**Input**: LinkedIn Profile URL

**Analysis**:
```yaml
profile_analysis:
  basic_info:
    name: "山田花子"
    current_role: "マーケティングマネージャー"
    company: "CloudTech株式会社"
    tenure: "1年3ヶ月"
    previous_companies:
      - "リクルート（3年）"
      - "サイバーエージェント（2年）"

  expertise_signals:
    skills:
      - "デジタルマーケティング"
      - "Google Analytics"
      - "コンテンツマーケティング"

    certifications:
      - "Google Analytics Individual Qualification"

    languages:
      - "日本語 (Native)"
      - "英語 (Business level)"

  content_analysis:
    posting_frequency: "週2回"
    topics:
      - "GA4活用法" (40%)
      - "マーケティング戦略" (35%)
      - "チームマネジメント" (25%)

    engagement_rate: "平均いいね15件、コメント3件"

    recent_posts:
      - date: "2025-11-08"
        content: "GA4のカスタムレポート作成に丸一日かかった...誰かテンプレート持ってませんか？"
        likes: 23
        comments: 5

        pain_point_detected: true
        relevance_to_mayu: 9/10

  connection_context:
    mutual_connections: 3
    mutual_connections_list:
      - "田中太郎（元同僚）"
      - "佐藤美咲（業界イベントで面識）"
      - "鈴木一郎（共通の顧客）"

  outreach_recommendation:
    approach: "problem_solution"
    opening_hook: "GA4カスタムレポートの件"
    personalization_level: "high"
    estimated_response_rate: 45%
```

### 3. パーソナライズDM生成（Personalized Message Generation）

**A/Bテストパターン**:

#### Pattern A: Feature-Benefit型
```markdown
山田さん、初めまして。

LinkedInでのGA4に関する投稿を拝見しました。
「カスタムレポート作成に丸一日」というお悩み、
多くのマーケターが同じ課題を抱えています。

私たちは、GA4分析を自動化するツール「Mayu」を開発しています。
カスタムレポート作成が3クリックで完了し、
これまで1日かかっていた作業が5分に短縮できます。

もしご興味があれば、30分の無料デモをご覧になりませんか？
貴社のGA4活用をさらに加速できると確信しています。

お時間いただけますでしょうか。
```

**特徴**:
- 製品機能を前面に押し出す
- メリットを数値で具体化（1日→5分）
- 直接的なCTA（デモ提案）

---

#### Pattern B: Empathy-Based型
```markdown
山田さん、初めまして。

「GA4カスタムレポート作成に丸一日」という投稿、
とても共感しました。

実は私も以前、同じ悩みを抱えていました。
分析よりもレポート作成に時間を取られ、
本来やるべき戦略立案に時間が割けない...

そこで開発したのが「Mayu」というツールです。
GA4の分析を自動化し、「次にやるべき施策」を提案します。

まだβ版なのですが、すでに5社のマーケターから
「分析工数が1/3になった」との声をいただいています。

もしよろしければ、30分だけお時間いただき、
山田さんのGA4活用の課題をお聞かせいただけませんか？

何かお役に立てるかもしれません。
```

**特徴**:
- 共感から入る
- 自分も同じ経験をしたストーリー
- ソフトなCTA（課題ヒアリング）
- 社会的証明（5社の実績）

---

#### Pattern C: Mutual Connection型
```markdown
山田さん、初めまして。

田中太郎さんから、山田さんのことを伺いました。
「GA4活用に力を入れている優秀なマーケター」と
お聞きしています。

私はマーケティングAIツール「Mayu」を開発しており、
田中さんにもβ版をご利用いただいています。

先日の山田さんの投稿（GA4カスタムレポートの件）を拝見し、
もしかしたらMayuがお役に立てるかもと思い、
ご連絡させていただきました。

田中さん経由でも構いませんので、
一度30分ほどお話しできれば幸いです。

よろしくお願いいたします。
```

**特徴**:
- 共通の知人から入る
- 信頼の転移
- 低圧的（田中さん経由でもOK）

---

### 4. A/Bテスト管理（A/B Test Management）

**テスト設計**:
```yaml
ab_test_config:
  test_name: "linkedin_outreach_wave1"
  duration: "14日間"
  sample_size: 200件

  variants:
    variant_a:
      name: "Feature-Benefit"
      allocation: 33%
      sample: 66件

    variant_b:
      name: "Empathy-Based"
      allocation: 33%
      sample: 67件

    variant_c:
      name: "Mutual Connection"
      allocation: 34%
      sample: 67件

  metrics:
    primary:
      - acceptance_rate: 接続承認率
      - response_rate: 返信率

    secondary:
      - time_to_response: 返信までの時間
      - conversation_depth: 会話継続率
      - meeting_booking_rate: 商談化率

  success_criteria:
    acceptance_rate_target: ">30%"
    response_rate_target: ">15%"
    meeting_booking_rate_target: ">10%"
```

**Results Tracking**:
```yaml
ab_test_results:
  variant_a_feature_benefit:
    sent: 66
    accepted: 18
    acceptance_rate: 27.3%

    responded: 8
    response_rate: 12.1%

    meetings_booked: 2
    meeting_rate: 3.0%

    avg_time_to_response: 48時間

  variant_b_empathy_based:
    sent: 67
    accepted: 25
    acceptance_rate: 37.3% ⭐ Winner

    responded: 14
    response_rate: 20.9% ⭐ Winner

    meetings_booked: 5
    meeting_rate: 7.5% ⭐ Winner

    avg_time_to_response: 24時間 ⭐ Winner

  variant_c_mutual_connection:
    sent: 67
    accepted: 22
    acceptance_rate: 32.8%

    responded: 11
    response_rate: 16.4%

    meetings_booked: 4
    meeting_rate: 6.0%

    avg_time_to_response: 36時間

  conclusion:
    winner: "Variant B (Empathy-Based)"
    reasoning:
      - 最高の承認率（37.3%）
      - 最高の返信率（20.9%）
      - 最高の商談化率（7.5%）
      - 最速の返信（24時間）

    recommendation: "今後は Variant B を80%、Variant C を20%の配分で実施"
```

### 5. フォローアップシーケンス（Follow-up Sequence）

**3-Touch Sequence**:

```yaml
sequence_config:
  trigger: "接続承認後、48時間返信なし"

  touch_1:
    timing: "承認後48時間"
    content: |
      山田さん、接続ありがとうございます！

      改めて、Mayuというマーケティング自動化ツールを開発している[名前]です。

      先日お送りしたメッセージ、お忙しい中恐縮です。
      もしGA4活用について何かお困りのことがあれば、
      お気軽にご相談ください。

      無料で30分のコンサルティングもしています。

  touch_2:
    timing: "Touch 1から5日後、返信なし"
    content: |
      山田さん

      先週、GA4の自動化についてお送りしましたが、
      タイミングが合わなかったかもしれません。

      もし今後、以下のようなお悩みがあればお声がけください：
      - レポート作成に時間がかかる
      - データから次の施策が見えない
      - チームのデータリテラシーが低い

      お役に立てることがあるかもしれません。

  touch_3:
    timing: "Touch 2から7日後、返信なし"
    content: |
      山田さん

      何度もすみません、これで最後にします。

      もし将来的にGA4やマーケティング自動化に
      ご興味を持たれましたら、お気軽にご連絡ください。

      引き続き、山田さんの投稿を楽しみにしています！

  final_action:
    timing: "Touch 3から14日後、返信なし"
    action: "シーケンス終了、リストから削除"
    note: "6ヶ月後に再アプローチ可能"
```

### 6. 商談化率分析（Conversion Analysis）

**Funnel Analysis**:
```yaml
linkedin_funnel:
  stage_1_outreach:
    sent: 200件

  stage_2_acceptance:
    accepted: 72件
    acceptance_rate: 36%
    drop_off: 128件 (64%)

  stage_3_response:
    responded: 28件
    response_rate: 38.9% (of accepted)
    overall_response_rate: 14% (of sent)
    drop_off: 44件 (61.1%)

  stage_4_conversation:
    deep_conversation: 18件
    conversation_rate: 64.3% (of responded)
    drop_off: 10件 (35.7%)

  stage_5_meeting:
    meetings_booked: 8件
    meeting_rate: 44.4% (of deep conversation)
    overall_conversion: 4% (of sent)

  stage_6_opportunity:
    qualified_opportunities: 5件
    qualification_rate: 62.5% (of meetings)

  roi_analysis:
    total_outreach: 200件
    qualified_opportunities: 5件
    conversion_rate: 2.5%

    cost_per_outreach: ¥100
    cost_per_opportunity: ¥4,000

    expected_deal_size: ¥300,000
    close_rate: 20%
    expected_revenue_per_opp: ¥60,000

    roi: 1,400%
```

---

## 🔗 Dependencies

### Upstream Dependencies
- **PersonaAgent**: ICP定義、ターゲット属性
- **SalesAgent**: 営業戦略、メッセージング
- **ContentCreationAgent**: アウトリーチ文案ベース

### Downstream Dependencies
- **CRMAgent**: リード情報登録、商談管理
- **AnalyticsAgent**: A/Bテスト分析、効果測定
- **SalesAgent**: 商談フォローアップ

---

## 🚀 Execution Workflow

### Phase 1: Target Extraction (Day 1-2)
```bash
1. ICP定義取得 (from PersonaAgent)
2. 企業リスト100社を解析
3. ターゲット200名抽出
4. プロフィール分析実行
5. 優先順位付け

Output: target_list_200.yaml
```

### Phase 2: Message Generation (Day 3-4)
```bash
1. A/Bテストパターン3種類準備
2. 各ターゲットに最適パターン割り当て
3. パーソナライゼーション実行
4. 200通のDM生成

Output: personalized_messages_200.yaml
```

### Phase 3: Outreach Execution (Day 5-14)
```bash
1. 1日20件ペースで送信
2. 承認・返信を毎日トラッキング
3. フォローアップシーケンス自動実行
4. 商談化したリードをCRMに転送

Output: daily_outreach_report.yaml
```

### Phase 4: Analysis & Optimization (Day 15-21)
```bash
1. A/Bテスト結果分析
2. 勝ちパターン特定
3. 次回Wave2のメッセージ最適化
4. ファネル分析レポート生成

Output:
  - ab_test_results.yaml
  - funnel_analysis.yaml
  - optimization_recommendations.md
```

---

## 📊 KPIs

### Input KPIs
- **月次アウトリーチ数**: 200件
- **ターゲット精度**: 90%以上（ICP適合率）

### Process KPIs
- **接続承認率**: 30%以上
- **返信率**: 15%以上
- **商談化率**: 10%以上（返信者の）

### Output KPIs
- **月次商談獲得数**: 20件
- **商談品質スコア**: 8/10以上
- **コスト/商談**: ¥5,000以下

---

## 🛠️ Technical Implementation

### APIs & Tools
```yaml
linkedin_tools:
  - LinkedIn Sales Navigator API
  - LinkedIn Messaging API
  - LinkedIn Profile Scraper

crm_integration:
  - HubSpot API
  - Salesforce API
  - Pipedrive API

analytics:
  - Google Sheets API (tracking)
  - Mixpanel (funnel analysis)

llm:
  - Claude Sonnet 4 (message generation)
  - GPT-4 (profile analysis)
```

### Rate Limits & Safety
```yaml
safety_measures:
  daily_limit: 20 connection requests
  hourly_limit: 5 connection requests

  message_throttling:
    min_interval: 15 minutes
    max_per_hour: 10

  spam_prevention:
    unique_message_ratio: ">70%"
    template_rotation: true
    personalization_required: true
```

---

## 📝 Example Execution

### Command
```bash
# LinkedInOutreachAgent実行（Mayu GTM Wave1）
npm run agents:linkedin-outreach -- \
  --issue 42 \
  --target-count 200 \
  --ab-test true \
  --daily-limit 20 \
  --duration 14
```

### Output
```
✅ Phase 1: Target Extraction
   - ICP適合企業: 98社
   - ターゲット抽出: 204名
   - 優先順位付け完了

✅ Phase 2: Message Generation
   - Variant A: 68通
   - Variant B: 68通
   - Variant C: 68通
   - パーソナライゼーション率: 95%

✅ Phase 3: Outreach Execution
   - Day 1-14: 200通送信完了
   - 承認: 72件 (36%)
   - 返信: 28件 (14%)
   - 商談化: 8件 (4%)

✅ Phase 4: Analysis
   - Winner: Variant B (Empathy-Based)
   - 推奨: 次回はVariant B 80%, C 20%
   - ROI: 1,400%
```

---

## 🎯 Use Cases

### Use Case 1: Mayu GTM Strategy
- **Task**: #42 Wave1実行開始
- **Goal**: 月20商談、商談化率33%
- **Timeline**: 14日間

### Use Case 2: Enterprise Sales
- **Task**: エンタープライズ顧客獲得
- **Goal**: 大口案件3件
- **Timeline**: 30日間

### Use Case 3: Partnership Outreach
- **Task**: 戦略的パートナー探索
- **Goal**: 提携候補10社
- **Timeline**: 21日間

---

## 🔄 Continuous Improvement

### Learning Loop
1. 毎月のA/Bテスト結果を蓄積
2. 業界別・役職別の最適パターン特定
3. 返信率の高い時間帯分析
4. メッセージ長さの最適化

### Version History
- **v1.0.0** (2025-11-10): 初版リリース
- **v1.1.0** (予定): LinkedIn Sales Navigator API統合
- **v2.0.0** (予定): AI返信機能追加

---

**Status**: ✅ Ready for Production
**Maintainer**: Miyabi Business Agent Team
**Last Updated**: 2025-11-10

🎯 **LinkedInOutreachAgent - 月200件のアウトリーチから20商談を創出！**
