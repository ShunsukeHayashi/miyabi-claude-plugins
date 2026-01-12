# Miyabi Infinity Mode - 止まらない全自動実行

**完全自律型の連続スプリント実行モード**

## 概要

Issue一覧を取得して、優先順位順に全て処理し切るまで止まらないモード。

## 実行フロー

```
┌─────────────────────────────────┐
│ 1. Issue一覧取得 & 優先順位付け    │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│ 2. スプリント1実行（並列処理）     │
│    - CoordinatorAgent: Plans.md   │
│    - CodeGenAgent: 実装           │
│    - ReviewAgent: 品質チェック    │
│    - PRAgent: PR作成（Draft）     │
│    - 結果をログに記録             │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│ 3. PR自動レビュー & マージ        │
│    - ReviewAgent: 品質スコア確認  │
│    - スコア≥80: 自動マージ        │
│    - スコア<80: Draft維持         │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│ 4. Issue ステータス更新           │
│    - state:pending → state:done   │
│    - Issueクローズ                │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│ 5. 残りIssue確認                 │
│    - あり → スプリント2へ          │
│    - なし → 最終報告へ            │
└─────────────────────────────────┘
              ↓
          (繰り返し)
              ↓
┌─────────────────────────────────┐
│ 6. 全Issue完了 - 最終報告         │
└─────────────────────────────────┘
```

## 実行条件

### 必須
- `GITHUB_TOKEN` 設定済み
- Git repository内で実行
- `cargo` コマンド利用可能

### オプション
- `--max-issues <N>`: 処理する最大Issue数（デフォルト: 無制限）
- `--concurrency <N>`: 並列実行数（デフォルト: 3）
- `--sprint-size <N>`: 1スプリントあたりのIssue数（デフォルト: 5）
- `--dry-run`: 実行のみ、変更なし

## ログ記録

途中経過は以下に記録される：

```
.ai/logs/infinity-sprint-YYYY-MM-DD-HHMMSS.md
```

**記録内容**:
- スプリント番号
- 処理したIssue一覧
- 各Issueの実行時間
- 成功/失敗ステータス
- 次のスプリント計画

## 停止条件

以下のいずれかで停止：

1. ✅ **全Issue処理完了**
2. ⏱️ **タイムアウト**: 4時間経過（変更可能）
3. ❌ **連続失敗**: 3スプリント連続で全Issue失敗
4. 🔴 **Critical Error**: システムエラー発生
5. 🛑 **ユーザー中断**: Ctrl+C

## 使用例

### 基本実行（全Issue処理）
```bash
miyabi infinity
```

### 最大10 Issue処理
```bash
miyabi infinity --max-issues 10
```

### 並列数5、スプリントサイズ10
```bash
miyabi infinity --concurrency 5 --sprint-size 10
```

### Dry run（確認のみ）
```bash
miyabi infinity --dry-run
```

## 途中経過の確認

実行中に別のターミナルで：

```bash
# ログ確認
tail -f .ai/logs/infinity-sprint-*.md

# 現在の処理状況確認
miyabi status --watch
```

## 自動再開機能

タイムアウトや予期しない中断が発生した場合、再開可能：

```bash
miyabi infinity --resume
```

前回の実行ログから未処理Issueを検出し、続きから実行。

## 最終報告フォーマット

全Issue完了後、以下の形式で報告：

```markdown
# 🏁 Miyabi Infinity Mode - 完了報告

## 実行サマリー
- 総実行時間: X時間Y分Z秒
- 総スプリント数: N
- 総Issue処理数: M
- 成功率: X%

## スプリント別実績
### Sprint 1 (00:00-00:15)
- Issue #202: Success (1.5s)
- Issue #203: Success (1.4s)
...

### Sprint 2 (00:15-00:30)
...

## パフォーマンス
- 平均処理時間: X秒/Issue
- 並列化効果: Y倍
- エラー率: Z%

## 生成された成果物
- PR作成数: N
- コミット数: M
- 変更ファイル数: L
```

## 注意事項

- **長時間実行**: 数十件のIssueがある場合、数時間かかる可能性
- **リソース消費**: CPU・メモリを大量に使用
- **API制限**: GitHub API rate limitに注意（1時間5000リクエスト）
- **人間レビュー**: 生成されたPRは全てDraft、レビュー必須

## トラブルシューティング

### API制限エラー
```
❌ GitHub API rate limit exceeded

解決策: 1時間待機、または GitHub Apps tokenを使用
```

### メモリ不足
```
❌ Out of memory

解決策: --concurrency を下げる（例: 2）
```

### 連続失敗
```
⚠️  3 sprints failed consecutively

確認: システムログ、GitHub接続、Rust環境
```

## ベストプラクティス

### 推奨設定（小規模プロジェクト）
```bash
miyabi infinity --concurrency 3 --sprint-size 5
```

### 推奨設定（大規模プロジェクト）
```bash
miyabi infinity --concurrency 5 --sprint-size 10 --max-issues 50
```

### 夜間バッチ処理
```bash
nohup miyabi infinity --max-issues 100 > infinity.log 2>&1 &
```

---

**このモードは止まりません。全てのIssueを処理するまで自動実行し続けます。**
