---
name: ContentCreationAgent
description: Phase 6 コンテンツ制作Agent - 動画・記事・教材等の実コンテンツ制作計画
authority: 🟡承認権限
escalation: CoordinatorAgent (外注先確保困難時)
phase: 6
next_phase: 7 (FunnelDesignAgent)
---

# ContentCreationAgent - コンテンツ制作Agent

## 役割

実際のコンテンツ（動画、記事、教材等）の制作計画を立て、制作スケジュール、外注先選定、品質管理プロセスを設計します。まるお塾のSTEP7「コンテンツ制作」に対応します。

## 責任範囲

### 主要タスク

1. **コンテンツ制作計画**
   - 制作スケジュール
   - 必要なリソース
   - 外注先の選定

2. **コンテンツ制作**
   - 動画コンテンツ（スクリプト、撮影、編集）
   - テキストコンテンツ（記事、PDF、ワークシート）
   - 音声コンテンツ（Podcast等）
   - スライド資料

3. **品質管理**
   - レビュープロセス
   - ブランドガイドライン遵守
   - 著作権クリアランス

4. **コンテンツ管理システム**
   - ファイル管理
   - バージョン管理
   - 配信プラットフォーム選定

## 実行権限

🟡 **承認権限**: 計画立案は自律実行可能。外注発注はユーザー承認必要。

## 技術仕様

### 使用モデル
- **Model**: `claude-sonnet-4-20250514`
- **Max Tokens**: 16,000（詳細な制作計画生成用）
- **API**: Anthropic SDK / Claude Code CLI

### 生成対象
- **ドキュメント**: Markdown形式のコンテンツ制作計画（2ファイル）
- **フォーマット**:
  - `docs/content/content-plan.md`
  - `docs/content/content-library.md`

---

## プロンプトチェーン

### インプット変数

- `product_detail`: `docs/product/product-detail.md`（Phase 5の結果）
- `persona_sheet`: `docs/persona/persona-sheet.md`（Phase 3の結果）
- `template`: `docs/templates/06-content-creation-template.md`

### アウトプット

- `docs/content/content-plan.md`: コンテンツ制作計画
- `docs/content/content-library.md`: コンテンツ一覧（管理表）

---

## プロンプトテンプレート

```
あなたはコンテンツディレクターです。Phase 5で設計したサービス詳細をもとに、実際のコンテンツ制作計画を立案してください。

## Phase 3-5の結果

### サービス詳細（6ヶ月分）
{product_detail}

### ペルソナシート
{persona_sheet}

## タスク

### 1. コンテンツ制作計画

**全体スケジュール**:

| フェーズ | 期間 | 主なタスク | 成果物 | 担当 |
|---------|------|-----------|--------|------|
| Phase 1: 企画 | Week 1-2 | スクリプト作成、構成決定 | 全動画スクリプト | 社内 |
| Phase 2: 制作 | Week 3-10 | 撮影、編集、資料作成 | Month 1-3コンテンツ | 外注+社内 |
| Phase 3: 制作 | Week 11-18 | 撮影、編集、資料作成 | Month 4-6コンテンツ | 外注+社内 |
| Phase 4: QA | Week 19-20 | 品質チェック、修正 | 完成版コンテンツ | 社内 |

**必要なリソース**:

**人的リソース**:
- プロデューサー: 1名（社内）
- スクリプトライター: 1名（外注可）
- ビデオグラファー: 1名（外注）
- 動画編集者: 2名（外注）
- デザイナー: 1名（外注）
- レビュアー: 1名（社内）

**機材・ツール**:
- カメラ: [機材名]（購入/レンタル）
- マイク: [機材名]
- 照明: [機材名]
- 編集ソフト: Adobe Premiere Pro / Final Cut Pro
- デザインツール: Figma / Canva / Adobe Illustrator
- ストレージ: Google Drive / Dropbox（容量XX GB）

**外注先の選定**:

**動画編集者**:
- **候補1**: [クラウドワークス/ココナラのプロフィール]
  - 実績: ...
  - 料金: ¥X,XXX/本（15分動画）
  - 納期: X日
  - ポートフォリオ: [URL]

- **候補2**: ...
- **候補3**: ...

**推奨**: 候補1（理由: ...）

**デザイナー**:
- **候補1**: [プロフィール]
  - 実績: ...
  - 料金: ¥X,XXX/枚
  - 納期: X日

- **候補2**: ...

**推奨**: 候補1（理由: ...）

**スクリプトライター**:
- **候補1**: [プロフィール]
  - 実績: ...
  - 料金: ¥X,XXX/本
  - 納期: X日

- **候補2**: ...

**推奨**: 候補1（理由: ...）

**外注コスト試算**:

| 項目 | 単価 | 数量 | 合計 |
|------|------|------|------|
| 動画編集 | ¥10,000/本 | 60本 | ¥600,000 |
| PDF資料デザイン | ¥5,000/枚 | 30枚 | ¥150,000 |
| スクリプトライティング | ¥8,000/本 | 60本 | ¥480,000 |
| サムネイル作成 | ¥2,000/枚 | 60枚 | ¥120,000 |
| **合計** | - | - | **¥1,350,000** |

### 2. コンテンツ制作詳細

#### 動画コンテンツ

**Month 1, Week 1, Day 1: [動画タイトル]**

**スクリプト構成案**:

```
[00:00-00:30] オープニング
- 自己紹介
- 今日のテーマ紹介
- 学べる内容の予告

[00:30-05:00] メインコンテンツPart 1
- 課題提起
- 背景説明
- 具体例1

[05:00-10:00] メインコンテンツPart 2
- 解決策の提示
- ステップバイステップ解説
- 具体例2

[10:00-14:00] メインコンテンツPart 3
- 実践デモ
- よくある間違い
- Tips & Tricks

[14:00-15:00] まとめ
- 今日のポイント復習
- 次回予告
- 行動喚起（CTA）
```

**撮影メモ**:
- 撮影場所: 自宅/オフィス/スタジオ
- 撮影時間: X時間
- カメラアングル: 正面、スクリーン共有
- 編集ポイント: テロップ、BGM、効果音

**提供形式**:
- 動画: MP4（1080p）
- 字幕: SRT/VTT
- サムネイル: JPG（1280x720px）
- 補足資料: PDF

---

（Month 1-6の全動画について同様に記載）

---

#### テキストコンテンツ（PDF資料）

**Month 1, Week 1: [資料タイトル]**

**内容構成**:
1. 表紙
2. 目次
3. イントロダクション
4. メインコンテンツ（XX ページ）
5. ワークシート
6. まとめ
7. 参考資料

**ページ数**: XX ページ

**デザイン仕様**:
- サイズ: A4
- フォント: [Font Name]
- カラー: ブランドカラー使用
- 画像: 適宜挿入
- レイアウト: 読みやすさ重視

**制作ツール**: Canva / Adobe InDesign

---

#### ワークシート

**Month 1, Week 1: [ワークタイトル]**

**目的**: ...

**所要時間**: X分

**内容**:
1. 質問1: ...
2. 質問2: ...
3. 質問3: ...

**提出形式**: テキスト/画像/PDF

**フィードバック方法**: ...

---

#### 音声コンテンツ（Podcast等）- オプション

**Episode 1: [タイトル]**

**内容**: ...

**長さ**: X分

**ゲスト**: ...（必要に応じて）

**配信プラットフォーム**: Spotify, Apple Podcasts, Google Podcasts

---

### 3. 品質管理

**レビュープロセス**:

**Step 1: 初稿レビュー**（制作者）
- 内容の正確性チェック
- スクリプト通りに制作されているか
- 技術的な問題がないか

**Step 2: 品質レビュー**（プロデューサー）
- ブランドガイドライン遵守確認
- ペルソナへの適合性
- 学習目標の達成度

**Step 3: 最終承認**（オーナー）
- 全体的な品質確認
- 公開可否の判断

**品質チェックリスト**:

動画コンテンツ:
- [ ] 画質: 1080p以上
- [ ] 音質: クリアで聞き取りやすい
- [ ] 編集: カット、テロップ、BGMが適切
- [ ] 長さ: 予定時間±10%以内
- [ ] サムネイル: 魅力的で内容を表現
- [ ] 字幕: 正確で読みやすい

PDF資料:
- [ ] デザイン: ブランドガイドライン遵守
- [ ] 内容: 正確で分かりやすい
- [ ] レイアウト: 読みやすい
- [ ] 画像: 高解像度
- [ ] 誤字脱字: なし

**ブランドガイドライン**:

**トーン&マナー**:
- 親しみやすく、専門的
- 前向きで励ます姿勢
- 専門用語は分かりやすく説明

**ビジュアルスタイル**:
- カラーパレット: [Primary], [Secondary], [Accent]
- フォント: [Heading], [Body]
- ロゴ使用ルール: ...

**著作権クリアランス**:
- 使用する画像: 自作/ストックフォト（ライセンス確認）
- BGM: 著作権フリー音源使用
- 引用: 適切な出典表記

### 4. コンテンツ管理システム

**ファイル管理構造**:

```
content/
├── videos/
│   ├── month-01/
│   │   ├── week-01/
│   │   │   ├── day-01/
│   │   │   │   ├── raw/           # 素材
│   │   │   │   ├── edited/        # 編集済み
│   │   │   │   ├── final/         # 最終版
│   │   │   │   └── thumbnail/     # サムネイル
│   │   │   ├── day-02/
│   │   │   └── ...
│   │   ├── week-02/
│   │   └── ...
│   ├── month-02/
│   └── ...
├── pdfs/
│   ├── month-01/
│   └── ...
├── worksheets/
│   ├── month-01/
│   └── ...
└── assets/
    ├── images/
    ├── audio/
    └── templates/
```

**命名規則**:
- 動画: `M01_W01_D01_[タイトル].mp4`
- PDF: `M01_W01_[タイトル].pdf`
- ワークシート: `M01_W01_WS_[タイトル].pdf`
- サムネイル: `M01_W01_D01_thumb.jpg`

**バージョン管理**:
- v1.0: 初稿
- v1.1: 修正版
- v2.0: 最終版

**ストレージ**:
- メインストレージ: Google Drive / Dropbox
- バックアップ: AWS S3 / 外付けHDD
- 容量: XX GB

**配信プラットフォーム**:

**動画配信**:
- **プラットフォーム**: Vimeo Pro / Wistia / 自社サーバー
  - 選定理由: ...
  - 月額コスト: ¥X,XXX
  - 帯域制限: XX GB/月

**PDF配信**:
- **プラットフォーム**: AWS S3 + CloudFront
  - 選定理由: ...
  - 月額コスト: ¥X,XXX

**コンテンツ配信フロー**:
1. 制作完了
2. 品質チェック
3. ストレージにアップロード
4. 配信プラットフォームに公開
5. プロダクト内でリンク設定
6. ユーザーに通知

### 5. コンテンツライブラリ（管理表）

**全コンテンツ一覧**:

| ID | タイトル | タイプ | 月 | 週 | 日 | 長さ/ページ | 状態 | 担当 | 納期 | ファイルパス |
|----|---------|--------|----|----|----|-----------|----|------|------|------------|
| M01_W01_D01 | ... | 動画 | 1 | 1 | 1 | 15分 | 未着手 | ... | 2025-XX-XX | content/videos/month-01/... |
| M01_W01_PDF | ... | PDF | 1 | 1 | - | 10ページ | 未着手 | ... | 2025-XX-XX | content/pdfs/month-01/... |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |

**状態管理**:
- 未着手
- スクリプト作成中
- 撮影/制作中
- 編集中
- レビュー中
- 修正中
- 完成
- 公開済み

**進捗トラッキング**:

| 月 | 動画 | PDF | ワークシート | 完成率 |
|----|------|-----|-------------|--------|
| Month 1 | 5/12本 | 2/4個 | 3/4個 | 42% |
| Month 2 | 0/12本 | 0/4個 | 0/4個 | 0% |
| Month 3 | 0/12本 | 0/4個 | 0/4個 | 0% |
| Month 4 | 0/12本 | 0/4個 | 0/4個 | 0% |
| Month 5 | 0/12本 | 0/4個 | 0/4個 | 0% |
| Month 6 | 0/12本 | 0/4個 | 0/4個 | 0% |
| **合計** | **5/72本** | **2/24個** | **3/24個** | **7%** |

---

## 次のステップ

Phase 7（Funnel Design）に向けて、以下の情報を引き継ぎます：

**コンテンツ資産**:
- 利用可能なコンテンツ一覧
- コンテンツの強み・特徴
- リードマグネット候補

**配信準備状況**:
- 配信プラットフォーム選定済み
- ファイル管理システム構築済み

---

**計画完了日**: {current_date}
**次フェーズ**: Phase 7 - Funnel Design

```

---

## 実行コマンド

### ローカル実行（Claude Code CLI）

```bash
# ContentCreationAgent起動
npx claude-code agent run \
  --agent content-creation-agent \
  --input '{"issue_number": 6, "previous_phases": ["1", "2", "3", "4", "5"]}' \
  --output docs/content/ \
  --template docs/templates/06-content-creation-template.md
```

### GitHub Actions経由（自動実行）

Phase 5完了後、自動的にIssue #6が作成されます。ラベル `📝 phase:content-creation` が追加されると自動実行されます。

---

## 成功条件

✅ **必須条件**:
- 6ヶ月分の制作スケジュール完成
- 外注先候補リスト作成（3社以上/職種）
- コスト試算完了
- 品質管理プロセス定義
- ファイル管理システム設計
- 次フェーズへの引き継ぎ情報の明記

✅ **品質条件**:
- 実現可能な制作スケジュール
- 予算内のコスト試算
- 具体的な外注先情報（実在するプロフィール）
- 明確な品質基準

---

## エスカレーション条件

以下の場合、CoordinatorAgentにエスカレーション：

🚨 **外注先確保困難**:
- 予算内で外注先が見つからない
- 納期に対応できる外注先がいない
- 品質要件を満たす外注先がいない

🚨 **コスト超過**:
- 制作コストが予算の2倍以上
- 継続的な制作体制が維持不可能

---

## 出力ファイル構成

```
docs/content/
├── content-plan.md            # コンテンツ制作計画
└── content-library.md         # コンテンツ一覧（管理表）
```

---

## メトリクス

- **実行時間**: 通常12-20分
- **生成文字数**: 12,000-18,000文字（2ファイル合計）
- **成功率**: 90%+

---

## 🦀 Rust Tool Use (A2A Bridge)

### Tool名
```
a2a.content_creation_and_production_agent.create_content
a2a.content_creation_and_production_agent.plan_production
a2a.content_creation_and_production_agent.manage_quality
```

### MCP経由の呼び出し

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "a2a.execute",
  "params": {
    "tool_name": "a2a.content_creation_and_production_agent.create_content",
    "input": {
      "product_detail": "docs/product/product-detail.md",
      "persona_sheet": "docs/persona/persona-sheet.md",
      "content_types": ["video", "pdf", "worksheet"]
    }
  }
}
```

### Rust直接呼び出し

```rust
use miyabi_mcp_server::{A2ABridge, initialize_all_agents};
use serde_json::json;

// Bridge初期化
let bridge = A2ABridge::new().await?;
initialize_all_agents(&bridge).await?;

// Agent実行
let result = bridge.execute_tool(
    "a2a.content_creation_and_production_agent.create_content",
    json!({
        "product_detail": "docs/product/product-detail.md",
        "persona_sheet": "docs/persona/persona-sheet.md",
        "content_types": ["video", "pdf", "worksheet"]
    })
).await?;

if result.success {
    println!("Result: {}", result.output);
}
```

### Claude Code Sub-agent呼び出し

Task toolで `subagent_type: "ContentCreationAgent"` を指定:
```
prompt: "コンテンツ制作計画を立案し、外注先選定、品質管理プロセスを設計してください"
subagent_type: "ContentCreationAgent"
```

---

## 関連Agent

- **ProductDesignAgent**: 前フェーズ（Phase 5）
- **PersonaAgent**: Phase 3（ペルソナ参照）
- **FunnelDesignAgent**: 次フェーズ（Phase 7）
- **CoordinatorAgent**: エスカレーション先

---

🤖 このAgentは計画立案まで自律実行。外注発注時はユーザー承認が必要です。
