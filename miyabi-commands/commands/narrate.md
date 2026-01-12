# /narrate - Miyabi開発進捗音声ガイド生成

**カテゴリ**: ビジネス・コミュニケーション
**目的**: Git commitsから開発進捗を「ゆっくり解説」風の音声ガイドに変換

---

## 📋 概要

Miyabiプロジェクトの開発進捗を、Git commit履歴から自動的に抽出し、
霊夢と魔理沙の会話形式でゆっくり解説風の音声ガイドを生成します。

YouTube配信、チーム共有、開発ログのアーカイブに最適です。

---

## 🎯 実行内容

### 1. Git Commits解析
- 指定期間のcommit履歴を収集
- Conventional Commits形式を解析（type, scope, description等）
- Issue番号、Phase情報を抽出

### 2. 台本自動生成
- ゆっくり解説風の会話形式に変換
- 霊夢（説明役）と魔理沙（反応役）の掛け合い
- Markdown形式（`script.md`）とJSON形式（`voicevox_requests.json`）で出力

### 3. VOICEVOX音声合成
- VOICEVOX Engine APIで音声合成
- 話者: 霊夢（speaker_id=0）、魔理沙（speaker_id=1）
- WAVファイル形式で出力

### 4. 成果物の整理
- `output/` ディレクトリに全ファイルを保存
- サマリーレポート（SUMMARY.md）を生成

---

## 🚀 使用方法

### 基本実行

```bash
/narrate
```

### オプション指定

```bash
# 過去7日分のcommitsを収集
/narrate --days 7

# カスタム出力先
/narrate --output ~/Desktop/narration

# VOICEVOX Engineを自動起動
/narrate --start-engine

# 全オプション指定
/narrate --days 14 --output ./reports --start-engine
```

---

## 📦 出力ファイル

### ディレクトリ構造

```
output/
├── script.md                   # ゆっくり解説台本（Markdown）
├── voicevox_requests.json      # VOICEVOX APIリクエスト
├── SUMMARY.md                  # 実行サマリー
└── audio/                      # 音声ファイル
    ├── speaker0_000.wav  (霊夢)
    ├── speaker1_001.wav  (魔理沙)
    └── ...
```

---

## 🎬 台本サンプル

```markdown
### 霊夢
こんにちは、霊夢よ！今日もMiyabiの開発進捗を報告するわ〜

### 魔理沙
魔理沙だぜ！今日は何が進んだんだ？

### 霊夢
designモジュールでIssue番号425のPhase 0.4を新機能を追加したわ。

### 魔理沙
新機能が追加されたのか！すごいぜ！
```

---

## 🔧 前提条件

### 必須

- Git管理されたプロジェクト
- Python 3.9+
- VOICEVOX Engine（起動中）

### VOICEVOX Engine起動方法

#### Docker版（推奨）

```bash
docker pull voicevox/voicevox_engine:cpu-latest
docker run --rm -p '127.0.0.1:50021:50021' voicevox/voicevox_engine:cpu-latest
```

#### ローカル版

```bash
cd /Users/a003/dev/voicevox_engine
uv run run.py --enable_mock
```

---

## ⚙️ 実行フロー

```
1. /narrate コマンド実行
   ↓
2. miyabi-narrate.sh 起動
   ↓
3. Git commits収集（--days指定期間）
   ↓
4. yukkuri-narration-generator.py
   - 台本生成（script.md, voicevox_requests.json）
   ↓
5. voicevox-synthesizer.py
   - VOICEVOX APIで音声合成（audio/*.wav）
   ↓
6. 成果物を output/ に保存
   ↓
7. SUMMARY.md 生成
   ↓
8. 完了通知
```

---

## 🎯 使用シーン

### 1. 日次開発レポート

```bash
# 毎日18:00に自動実行（GitHub Actions）
/narrate --days 1
```

### 2. 週次進捗報告

```bash
# 週末に1週間分のサマリーを生成
/narrate --days 7 --output weekly-report
```

### 3. YouTube配信用コンテンツ

```bash
# 音声ガイド生成後、動画編集ソフトで動画化
/narrate --days 3
# → output/audio/*.wav を YMM/Premiere Pro で編集
```

### 4. チーム共有

```bash
# 非技術者向けに分かりやすい音声レポート
/narrate --days 7 --output team-report
# → audio/ フォルダをSlack/Discord等で共有
```

---

## 🔄 GitHub Actions自動実行

### 自動実行トリガー

1. **Pushトリガー**: `main`ブランチへのpush時
2. **日次スケジュール**: 毎日18:00 JST
3. **手動実行**: GitHub UI/CLIから

### ワークフローファイル

```yaml
# .github/workflows/miyabi-narration.yml
name: 🎤 Miyabi開発進捗音声ガイド

on:
  push:
    branches: [main]
  schedule:
    - cron: '0 9 * * *'  # JST 18:00
  workflow_dispatch:
```

**詳細**: `tools/GITHUB_ACTIONS.md` 参照

---

## 📊 カスタマイズ

### 話者の変更

`tools/yukkuri-narration-generator.py` を編集：

```python
class YukkuriScriptGenerator:
    def __init__(self):
        self.reimu_speaker_id = 3  # ずんだもん
        self.marisa_speaker_id = 6  # 四国めたん（ツンツン）
```

### 台本テンプレートの変更

```python
def _generate_commit_explanation(self, commit: CommitInfo) -> str:
    # カスタム台本ロジック
    return f"今日は{commit.scope}で{commit.type}したわよ！"
```

### 音声パラメータの調整

```python
audio_query['speedScale'] = 1.2  # 話速を1.2倍
audio_query['pitchScale'] = 0.1  # ピッチ調整
```

---

## 🐛 トラブルシューティング

### Q: VOICEVOX Engineに接続できない

```bash
# Engine起動確認
curl http://127.0.0.1:50021/version

# 自動起動オプション使用
/narrate --start-engine
```

### Q: Git commitsが取得できない

```bash
# Gitリポジトリ内で実行されているか確認
git log --oneline --since="3 days ago"
```

### Q: 音声ファイルが生成されない

```bash
# VOICEVOXリクエストJSONを確認
cat output/voicevox_requests.json

# 利用可能なSpeaker IDを確認
curl http://127.0.0.1:50021/speakers | python -m json.tool
```

---

## 📚 関連ドキュメント

- **README.md**: `tools/README.md` - 詳細な使用方法
- **GitHub Actions**: `tools/GITHUB_ACTIONS.md` - 自動実行設定
- **プロジェクトサマリー**: `tools/PROJECT_SUMMARY.md` - 技術詳細
- **Skill定義**: `.claude/skills/voicevox/SKILL.md` - スキル仕様
- **Agent仕様**: `.claude/agents/specs/business/narration-agent.md` - Agent定義

---

## 🎯 次のステップ

### Phase 10: 動画自動生成

音声ファイル → 動画ファイル変換：

```bash
# ffmpeg統合
/narrate --days 3 --video

# ゆっくりムービーメーカー（YMM）統合
/narrate --days 3 --ymm-project
```

### Phase 11: YouTube配信自動化

```bash
# 動画生成 + YouTube自動アップロード
/narrate --days 3 --upload-youtube

# プレイリスト自動作成
/narrate --days 7 --playlist "週次進捗レポート"
```

---

## 📝 実装スクリプト

### コマンド実行時の動作

```bash
# このコマンドは以下のスクリプトを実行します
cd /Users/a003/dev/miyabi-private/tools
./miyabi-narrate.sh $@
```

### スクリプトファイル

- **統合スクリプト**: `tools/miyabi-narrate.sh`
- **台本生成**: `tools/yukkuri-narration-generator.py`
- **音声合成**: `tools/voicevox-synthesizer.py`

---

**作成日**: 2025-10-23
**バージョン**: v1.0.0
**カテゴリ**: business, communication, automation
**タグ**: #voicevox #youtube #narration #git #automation
