# Miyabi Slash Commands Index

**Last Updated**: 2025-11-04
**Total Commands**: 22

スラッシュコマンドの完全インデックス。カテゴリ別に整理されています。

---

## 📋 Quick Reference

| Command | Category | Description |
|---------|----------|-------------|
| `/create-issue` | 🛠️ Development | GitHub Issue作成（Agent実行用・汎用両対応） |
| `/agent-run` | 🤖 Agent | Agent実行（単一/並列/バッチ） |
| `/miyabi-auto` | 🤖 Agent | 全自動開発モード起動 |
| `/miyabi-infinity` | 🤖 Agent | Infinity Sprint起動（無限自律実行） |
| `/test` | 🛠️ Development | プロジェクト全体テスト実行 |
| `/verify` | 🛠️ Development | システム動作確認（環境・コンパイル・テスト） |
| `/review` | 🛠️ Development | コード品質レビュー |
| `/security-scan` | 🔒 Security | セキュリティ脆弱性スキャン |
| `/deploy` | 🚀 Deployment | Firebase/Cloud デプロイ実行 |
| `/generate-docs` | 📝 Documentation | コードからドキュメント自動生成 |
| `/generate-lp` | 📝 Documentation | ランディングページ生成 |
| `/daily-update` | 📊 Reports | 毎日の開発進捗レポート生成（note.com投稿用） |
| `/miyabi-todos` | 📋 Planning | TODO コメント自動検出・Issue化 |
| `/session-end` | 🔔 Notifications | セッション終了通知（macOS通知+音声） |
| `/voicevox` | 🔊 VoiceVox | 単発テキスト読み上げ |
| `/narrate` | 🔊 VoiceVox | Git commitから開発進捗ナレーション生成 |
| `/watch-sprint` | 🔊 VoiceVox | Infinity Sprintログ監視 + 音声通知 |
| `/check-benchmark` | 📊 Benchmarks | ベンチマーク実装チェック |
| `/pattern3` | 🚀 Workflow | Pattern 3 Hybrid Orchestration起動 |
| `/pattern3-report` | 📊 Reports | Pattern 3実行結果レポート生成 |
| `/claude-code-x` | 🤖 Agent | Claude Codeバックグラウンド自律実行 |
| `/codex` | 🤖 Agent | Codex X統合（GPT-5/o3並列実行） |
| `/tmux-control` | 🤖 Agent | TmuxControlAgentでセッション管制 |

---

## 🗂️ Category Details

### 🛠️ Development Commands

#### `/create-issue` - GitHub Issue作成
**File**: `create-issue.md` (8.1KB)
**Usage**: `/create-issue` または `/create-issue --simple`

Agent実行用の詳細Issueから、シンプルな汎用Issueまで対話的に作成。

**機能**:
- Conventional Commits形式のタイトル推奨
- 自動ラベル付与（53ラベル体系）
- Agent自動実行設定
- バッチ作成対応（YAML）

---

#### `/test` - プロジェクト全体テスト
**File**: `test.md`
**Usage**: `/test`

`cargo test --all` を実行し、プロジェクト全体のテストを実行。

---

#### `/verify` - システム動作確認
**File**: `verify.md` (4.1KB)
**Usage**: `/verify`

環境・コンパイル・テストを全チェック。

**確認項目**:
- Rust環境 (rustc, cargo)
- 依存関係
- コンパイル
- テスト実行
- セキュリティスキャン

---

#### `/review` - コード品質レビュー
**File**: `review.md` (12KB)
**Usage**: `/review`

ReviewAgentによる自動コードレビュー（100点満点スコアリング）。

**レビュー項目**:
- コード品質
- セキュリティ
- パフォーマンス
- テストカバレッジ
- ドキュメント

---

### 🤖 Agent Commands

#### `/agent-run` - Agent実行
**File**: `agent-run.md` (8.8KB)
**Usage**: `/agent-run <agent-name> --issue <issue-id>`

単一Agent実行、並列実行、バッチ実行に対応。

**例**:
```bash
/agent-run coordinator --issue 270
/agent-run codegen --issues 270,271,272 --concurrency 3
```

---

#### `/miyabi-auto` - 全自動開発モード
**File**: `miyabi-auto.md` (6.3KB)
**Usage**: `/miyabi-auto`

Issue作成からコード実装、PR作成、デプロイまで完全自動化。

**実行フロー**:
1. IssueAgent: Issue分析・ラベリング
2. CoordinatorAgent: タスクDAG分解
3. CodeGenAgent: コード生成
4. ReviewAgent: 品質レビュー
5. PRAgent: Pull Request作成
6. DeploymentAgent: デプロイ

---

#### `/miyabi-infinity` - Infinity Sprint
**File**: `miyabi-infinity.md` (5.9KB)
**Usage**: `/miyabi-infinity`

無限自律実行モード。Issueを自動的に処理し続ける。

**特徴**:
- 自動Issue取得
- 並列実行（max 3並列）
- 失敗時自動リトライ
- 音声通知対応

---

#### `/miyabi-todos` - TODO自動Issue化
**File**: `miyabi-todos.md` (8.3KB)
**Usage**: `/miyabi-todos`

コード中のTODOコメントを自動検出してIssue化。

**検出パターン**:
- `// TODO: ...`
- `# TODO: ...`
- `<!-- TODO: ... -->`

---

### 🔒 Security Commands

#### `/security-scan` - セキュリティスキャン
**File**: `security-scan.md` (10KB)
**Usage**: `/security-scan`

包括的なセキュリティ脆弱性スキャン。

**スキャン項目**:
- 依存関係の脆弱性（cargo-audit）
- シークレット検出（gitleaks）
- コード静的解析（clippy）
- OWASP Top 10チェック

---

### 🚀 Deployment Commands

#### `/deploy` - デプロイ実行
**File**: `deploy.md` (6.8KB)
**Usage**: `/deploy [target]`

Firebase/Cloud デプロイを自動実行。

**対応環境**:
- Firebase Hosting
- Cloud Run
- GitHub Pages

---

### 📝 Documentation Commands

#### `/generate-docs` - ドキュメント自動生成
**File**: `generate-docs.md` (12KB)
**Usage**: `/generate-docs`

コードからドキュメントを自動生成（Entity-Relationモデル準拠）。

**生成内容**:
- API仕様書
- アーキテクチャ図
- Agent仕様書
- テンプレート

---

#### `/generate-lp` - ランディングページ生成
**File**: `generate-lp.md` (7.3KB)
**Usage**: `/generate-lp`

プロジェクトのランディングページを自動生成。

---

### 📊 Reports & Planning

#### `/daily-update` - 開発進捗レポート
**File**: `daily-update.md` (11KB)
**Usage**: `/daily-update`

毎日の開発進捗を自動レポート（note.com投稿用）。

**レポート内容**:
- Git commits サマリ
- Issue進捗
- PR統計
- テストカバレッジ

---

#### `/check-benchmark` - ベンチマーク実装チェック
**File**: `check-benchmark.md` (2.2KB)
**Usage**: `/check-benchmark`

公式ベンチマークハーネス使用の確認。

---

### 🚀 Workflow Commands

#### `/pattern3` - Pattern 3 Hybrid Orchestration起動
**File**: `pattern3.md`
**Usage**: `/pattern3`

Main Session（Claude Code）+ Codex X + Claude Code Xの3セッション並列実行により、生産性を140%向上。

**並列実行フロー**:
```
Main (Claude Code): 統合・意思決定・レビュー
 ├── Background 1 (Codex X): Zero-bug品質コード
 └── Background 2 (Claude Code X): 高速ドキュメント
```

**利点**:
- ✅ Main中断ゼロ
- ✅ 異なるAIモデルの強み活用
- ✅ 生産性140%向上

---

#### `/pattern3-report` - Pattern 3レポート生成
**File**: `pattern3-report.md`
**Usage**: `/pattern3-report`

Pattern 3実行結果を包括的にレポート。

**レポート内容**:
- Main/Codex X/Claude Code Xの成果
- 生産性指標（並列タスク数、実行時間等）
- 品質指標（ビルド成功率、テスト合格率等）
- Lessons Learned
- Next Steps

**出力**: `/tmp/pattern3_final_report.md`

---

### 🔔 Notifications

#### `/session-end` - セッション終了通知
**File**: `session-end.md` (4.9KB)
**Usage**: `/session-end`

開発セッション終了を通知（macOS通知+牛の鳴き声🐮）。

---

### 🔊 VoiceVox Commands

#### `/voicevox` - 単発テキスト読み上げ
**File**: `voicevox.md` (1.7KB)
**Usage**: `/voicevox "テキスト" [speaker] [speed]`

VoiceVoxで任意テキストを読み上げ。

**例**:
```bash
/voicevox "やぁやぁ!ずんだもんなのだ!" 3 1.2
```

---

#### `/narrate` - 開発進捗ナレーション
**File**: `narrate.md` (7.0KB)
**Usage**: `/narrate`

Git commitsから開発進捗をゆっくり解説音声に変換。

**生成内容**:
- コミットサマリ
- 変更ファイル解説
- 影響範囲分析

---

#### `/watch-sprint` - Sprint監視 + 音声通知
**File**: `watch-sprint.md` (2.3KB)
**Usage**: `/watch-sprint`

Infinity Sprintのログをリアルタイム監視し、イベント発生時に音声通知。

**通知イベント**:
- Sprint開始: "スプリントが始まるのだ！"
- タスク成功: "やったのだ！タスクが1つ完了したのだ！"
- タスク失敗: "失敗したのだ！でも諦めないのだ！"
- 全完了: "全部終わったのだ！お疲れ様なのだ！"

---

### 🔮 Advanced Execution Commands

#### `/claude-code-x` - Claude Code バックグラウンド自律実行
**File**: `claude-code-x.md` (5.4KB), `claude-code-x.sh` (12KB)
**Usage**: `/claude-code-x exec "Task description"`

Claude Codeをバックグラウンドで自律実行。Codex Xと同様のインターフェースで高速処理。

**特徴**:
- 🚀 **高速**: Codex Xの3倍速（1m46s vs 6m16s+）
- 🎯 **高品質**: Claude Sonnet 4.5による精密実装
- 📊 **セッション管理**: 最大5並列セッション
- 🔍 **リアルタイム監視**: status/result コマンド対応

**コマンド**:
```bash
/claude-code-x exec "Task description"           # タスク実行
/claude-code-x sessions                          # セッション一覧
/claude-code-x status <session-id>               # ステータス確認
/claude-code-x result <session-id>               # 結果取得
/claude-code-x kill <session-id>                 # セッション終了
/claude-code-x cleanup                           # 古いセッション削除
```

**オプション**:
- `--tools "Tool1,Tool2"` - 使用ツール指定（デフォルト: Bash,Read,Write,Edit,Glob,Grep）
- `--timeout 600` - タイムアウト秒数（デフォルト: 600秒）

**使用例**:
```bash
# 基本実行
/claude-code-x exec "Implement user authentication with JWT"

# カスタムツール指定
/claude-code-x exec "Research AI news" --tools "WebSearch,Read,Write"

# タイムアウト指定
/claude-code-x exec "Run full test suite" --timeout 1200

# セッション監視
/claude-code-x sessions
/claude-code-x status claude-code-x-20251031-123456-abc123
tail -f .ai/sessions/claude-code-x/logs/claude-code-x-20251031-123456-abc123.log
```

**vs Codex X**:

| Feature | Codex X | Claude Code X |
|---------|---------|---------------|
| **Model** | GPT-5 Codex/o3 | Claude Sonnet 4.5 |
| **Speed** | 遅い (6分+) | 速い (1-2分) |
| **Quality** | バグゼロ | 高品質 (修正1回程度) |
| **Interactive** | ❌ | ✅ (別セッション) |
| **Session Resume** | ✅ `--continue` | ✅ (計画中) |

**Optimal Workflow**:
```bash
# Main session: Planning & Orchestration
> "Let's implement Feature X. First, plan the tasks..."

# Background: Autonomous implementation
> /claude-code-x exec "Implement Feature X based on plan"

# Continue main work while Claude Code X runs
> "Now let's work on Feature Y..."

# Check progress
> /claude-code-x status

# Review results
> /claude-code-x result <session-id>
```

**関連スクリプト**:
- `scripts/generate-ai-blog.sh` - AI news blog article generator (uses Claude Code X with WebSearch)

---

#### `/codex` - Codex X統合
**File**: `codex.md` (5.2KB), `codex.sh` (12KB)
**Usage**: `/codex exec "Task description"`

GPT-5 Codex/o3によるゼロバグ品質コード生成（外部統合）。

**特徴**:
- 🎯 **ゼロバグ**: 高精度な実装
- 🔄 **セッション再開**: `--continue` でレジューム
- 📊 **詳細レポート**: 実行結果の自動レポート生成

**コマンド**:
```bash
/codex exec "Task description"                   # タスク実行
/codex continue <session-id> "Additional task"   # セッション継続
/codex sessions                                  # セッション一覧
/codex status <session-id>                       # ステータス確認
```

**Pattern 3 Hybrid Orchestration**:
- Main Session (Claude Code): 統合・意思決定・レビュー
- Background 1 (Codex X): Zero-bug品質コード
- Background 2 (Claude Code X): 高速ドキュメント
- 生産性140%向上を実現

---

#### `/tmux-control` - tmux セッション管制
**File**: `tmux-control.md` (4.5KB)
**Usage**: `/tmux-control session=<name> pane=%n command="..." mode=send|capture|recover|status`

TmuxControlAgent（つむっくん）が `send-keys` の安全注入、ログ収集、復旧シーケンスを管理して tmux セッションを安定化。Infinity Mode や Orchestra の CLI 操作を AI 主導で行う際の基盤コマンド。

**主なユースケース**:
- セッション整備: `/tmux-control mode=recover`
- コマンド投入: `/tmux-control pane=%2 command="cd ... && ./scripts/miyabi-orchestra.sh coding-ensemble"`
- ログ取得: `/tmux-control pane=%4 mode=capture`
- 状態確認: `/tmux-control session=Miyabi mode=status`

**参照資料**:
- `/docs/TMUX_AI_AGENT_CONTROL_GUIDE.md`
- `.claude/guides/TMUX_AI_AGENT_CONTROL.md`
- `.claude/agents/specs/coding/tmux-control-agent.md`

復旧不能な場合は CoordinatorAgent に `status:critical` を返し、人間オペレーターへ通知する設計。

---

## 🔗 Related Documentation

- **CLAUDE.md** - プロジェクトコンテキスト
- **Context Index** - `.claude/context/INDEX.md`
- **Agent Specs** - `.claude/agents/specs/`
- **Templates** - `docs/templates/`

---

## 📈 Usage Statistics

**Most Used Commands**:
1. `/agent-run` - Agent実行
2. `/create-issue` - Issue作成
3. `/test` - テスト実行
4. `/verify` - 動作確認
5. `/miyabi-auto` - 全自動モード

---

**このINDEXは動的に更新されます。新規コマンド追加時は自動的に反映されます。**

🤖 Generated with [Claude Code](https://claude.com/claude-code)
