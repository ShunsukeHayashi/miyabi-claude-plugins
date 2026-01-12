# /live - LIVE実況モードコマンド

**カテゴリ**: 開発・監視・実況
**目的**: リアルタイム開発進捗を音声付きで実況

---

## 📋 概要

開発作業をリアルタイムで監視し、重要なイベント（コミット、テスト、ビルド等）を音声でアナウンスするLIVE実況モードです。

---

## 🎯 実行内容

以下のBashコマンドを実行してください：

```bash
# LIVE実況モード実行
tools/live_mode.sh

# または特定のモードで実行
tools/live_mode.sh git        # Git監視のみ
tools/live_mode.sh files      # ファイル変更監視のみ
tools/live_mode.sh tests      # テスト実行監視のみ
tools/live_mode.sh build      # ビルド監視のみ
tools/live_mode.sh resources  # システムリソース監視のみ

# ヘルプ表示
tools/live_mode.sh --help

# 進捗レポート生成
tools/live_mode.sh --report

# カスタムアナウンス
tools/live_mode.sh --announce "テスト完了！"
```

---

## 🚀 機能

### 📊 監視項目

1. **Git状態監視**
   - コミット検出
   - ブランチ変更検出
   - 自動音声アナウンス

2. **ファイル変更監視**
   - Cargo.toml, Cargo.lock, .miyabi.yml
   - crates/ ディレクトリ
   - リアルタイム変更検知

3. **テスト実行監視**
   - cargo test 実行検知
   - テスト進捗アナウンス
   - 成功/失敗通知

4. **ビルド監視**
   - cargo build 実行検知
   - ビルド開始/完了アナウンス
   - コンパイル進捗通知

5. **システムリソース監視**
   - CPU使用率監視
   - メモリ使用率監視
   - 高負荷時の警告

### 🎤 音声アナウンス

- **VOICEVOX統合**: ずんだもん（デフォルト）で音声合成
- **カスタマイズ可能**: 話者ID、速度、メッセージ設定
- **キュー管理**: 複数アナウンスの順次再生

### 📈 進捗レポート

- **自動生成**: 5分ごとにMarkdownレポート作成
- **保存場所**: `/tmp/miyabi_live/progress_report_*.md`
- **内容**: システム状況、テスト状況、リソース使用率

---

## 🎛️ 設定

### 設定ファイル: `/tmp/miyabi_live/live_config.json`

```json
{
  "voice_enabled": true,
  "speaker_id": 3,
  "speed": 1.2,
  "update_interval": 5,
  "max_queue_size": 10,
  "announcements": {
    "test_start": "テスト開始なのだ！",
    "test_pass": "テスト成功！やったのだ！",
    "test_fail": "テスト失敗...でも次は頑張るのだ！",
    "build_start": "ビルド開始なのだ！",
    "build_success": "ビルド成功！完璧なのだ！",
    "build_fail": "ビルド失敗...デバッグが必要なのだ",
    "commit": "コミット完了！進歩したのだ！",
    "session_start": "セッション開始！頑張るのだ！",
    "session_end": "お疲れ様！また次回なのだ！"
  }
}
```

### 話者ID一覧

| ID | 名前 | 特徴 |
|----|------|------|
| 2 | 四国めたん | 女性、かわいい |
| 3 | ずんだもん | 女性、元気（デフォルト） |
| 8 | 春日部つむぎ | 女性、明るい |
| 9 | 波音リツ | 女性、落ち着き |

---

## 🔧 前提条件

### 必須
- VOICEVOX Engine起動中（`http://localhost:50021`）
- `tools/voicevox_enqueue.sh` 実行可能
- `tools/voicevox_worker.sh` 実行可能

### 推奨
- `jq` コマンド（JSON設定ファイル用）
- `inotifywait` コマンド（ファイル監視用）
- `bc` コマンド（数値計算用）

---

## 📖 使用例

### 基本実行
```bash
# フル監視モード（全機能）
tools/live_mode.sh

# Git監視のみ
tools/live_mode.sh git
```

### カスタムアナウンス
```bash
# 特定のメッセージをアナウンス
tools/live_mode.sh --announce "リファクタリング完了！"

# 進捗レポート生成
tools/live_mode.sh --report
```

### 設定確認
```bash
# 設定ファイル表示
tools/live_mode.sh --config

# ヘルプ表示
tools/live_mode.sh --help
```

---

## 🐛 トラブルシューティング

### Q: VOICEVOX音声が再生されない
```bash
# VOICEVOX Engine起動確認
curl http://127.0.0.1:50021/version

# ワーカープロセス確認
pgrep -f "voicevox_worker.sh"

# キュー状況確認
ls -la /tmp/voicevox_queue/
```

### Q: ファイル監視が動作しない
```bash
# inotifywait確認
which inotifywait

# フォールバックモード（定期的チェック）が自動使用される
```

### Q: 設定ファイルが見つからない
```bash
# 設定ファイル確認
ls -la /tmp/miyabi_live/live_config.json

# 手動で設定ファイル作成
mkdir -p /tmp/miyabi_live
echo '{"voice_enabled": true, "speaker_id": 3, "speed": 1.2}' > /tmp/miyabi_live/live_config.json
```

---

## 📚 関連コマンド

- `/voicevox` - 単発音声合成
- `/narrate` - Git commitから開発進捗ナレーション生成
- `/watch-sprint` - Infinity Sprintログ監視 + 音声通知
- `/session-end` - セッション終了通知 + 音声ガイド

---

## 🎬 実況例

```
🔴 LIVE実況モード開始 🎤
===============================================

ℹ️ フル監視モード
🎤 LIVE実況モード開始！みんなで頑張るのだ！
📹 ファイル変更監視開始...
⚡ ファイル変更: crates/miyabi-cli/src/main.rs
🎤 ファイル変更検出！crates/miyabi-cli/src/main.rs
⭐ 新しいコミット: refactor: Update CLI configuration
🎤 コミット検出！refactor: Update CLI configuration
🧠 テスト実行中... (15個)
🎤 テスト実行中！頑張るのだ！
⚙️ ビルド開始...
🎤 ビルド開始！コンパイル頑張るのだ！
✅ ビルド完了
🎤 ビルド完了！成功したのだ！
```

---

**作成日**: 2025-10-28
**バージョン**: v1.0.0
**カテゴリ**: development, monitoring, live-streaming, voicevox
**タグ**: #live #monitoring #voicevox #real-time #development

--- End Command ---







