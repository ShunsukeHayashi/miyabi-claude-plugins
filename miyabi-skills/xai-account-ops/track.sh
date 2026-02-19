#!/usr/bin/env bash
set -euo pipefail

# xAI トレンド追跡スクリプト
# 使用方法: ./track.sh [keywords|compare|history] [args...]

# 環境変数読み込み
if [ -f "$HOME/.config/claude-env/tokens.conf" ]; then
    source "$HOME/.config/claude-env/tokens.conf"
fi

# スクリプトディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYWORDS_FILE="${SCRIPT_DIR}/keywords.txt"
HISTORY_DIR="${SCRIPT_DIR}/history"
mkdir -p "$HISTORY_DIR"

# API設定
API_BASE="https://api.x.ai/v1"
MODEL="grok-4-fast"

# xAI API呼び出し
call_xai() {
    local prompt="$1"
    local tools="$2"

    local payload=$(jq -n \
        --arg model "$MODEL" \
        --arg prompt "$prompt" \
        --argjson tools "$tools" \
        '{
            model: $model,
            tools: [$tools],
            input: $prompt
        }')

    curl -s "${API_BASE}/responses" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $XAI_API_KEY" \
        -d "$payload"
}

# キーワードからトレンド検索
track_keywords() {
    local format="${2:-markdown}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="${HISTORY_DIR}/trend_${timestamp}.json"

    echo "🔍 トレンドキーワード検索中..."

    # キーワードファイルからキーワードを読み込み
    if [ ! -f "$KEYWORDS_FILE" ]; then
        echo "エラー: キーワードファイルが見つかりません: $KEYWORDS_FILE"
        exit 1
    fi

    # キーワードを配列として取得（コメント行と空行を除外）
    local keywords=$(grep -v '^#' "$KEYWORDS_FILE" | grep -v '^$' | tr '\n' '|' | sed 's/^|/"/' | sed 's/$/"/' | tr '\n' ',')

    if [ -z "$keywords" ]; then
        echo "エラー: キーワードが見つかりません"
        exit 1
    fi

    echo "📋 ターゲットキーワード: $(echo "$keywords" | jq -R 'split(",") | .[]' -c)"

    local prompt="以下のキーワードに関連する、最近バズっている日本語投稿TOP5を教えてください。エンゲージメント数、投稿内容、傾向を分析してください。

キーワード: $(echo "$keywords" | jq -R 'split(",") | .[]' -c)"

    local tools='{"type":"x_search"}'

    local response=$(call_xai "$prompt" "$tools")
    echo "$response" > "$output_file"

    local content=$(echo "$response" | jq -r '.output[1].content[0].text // .output[0].content[0].text // empty')

    if [ "$format" = "json" ]; then
        local report_file="${HISTORY_DIR}/trend_${timestamp}_report.json"
        cat > "$report_file" << EOF
{
  "report_type": "trend_tracking",
  "keywords": [$(echo "$keywords" | jq -R 'split(",") | .[]' -c)],
  "generated_at": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "api_model": "${MODEL}",
  "raw_response": $(echo "$response" | jq -c '.output[1].content[0]')
}
EOF
        echo ""
        echo "📄 JSONレポート: $report_file"
    else
        local report_file="${HISTORY_DIR}/trend_${timestamp}_report.md"
        cat > "$report_file" << EOF
# トレンド追跡レポート

**生成日時**: $(date '+%Y-%m-%d %H:%M:%S')
**対象キーワード**: $(echo "$keywords" | jq -R 'split(",") | .[]' -c)

---

## トレンド分析結果

${content}

---

*本レポートは xAI API (Grok-4) によって生成されました*
EOF
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$report_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📄 Markdownレポート: $report_file"
    fi

    echo "✅ 生データ保存: $output_file"
}

# 履歴比較
compare_history() {
    local count="${1:-5}"

    echo "📊 直近 ${count}件の履歴を比較..."

    local history_files=$(ls -t "$HISTORY_DIR"/trend_*_report.json 2>/dev/null | head -"$count")

    if [ -z "$history_files" ]; then
        echo "エラー: 履歴ファイルが見つかりません"
        exit 1
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "# トレンド推移レポート"
    echo ""
    echo "**生成日時**: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "**比較対象**: 直近 ${count}件"
    echo ""
    echo "## 履歴一覧"
    echo ""

    for file in $history_files; do
        local filename=$(basename "$file")
        local timestamp=$(echo "$filename" | sed 's/trend_\([0-9]*\)_report.json/\1/')
        local formatted_date=$(echo "$timestamp" | sed 's/_\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)_\([0-9][0-9]\)\([0-9][0-9]\)/\1-\2-\3 \4:\5/')
        local keywords=$(jq -r '.keywords // "unknown"' "$file" 2>/dev/null | jq -R 'join(", ")')

        echo "- **${formatted_date}**"
        echo "  - キーワード: ${keywords}"
        echo "  - ファイル: ${filename}"
        echo ""
    done

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 定期実行対応（cron用）
cron_track() {
    local interval="${1:-3}"  # 間隔（時間）
    local max_history="${2:-30}" # 保持する履歴数

    echo "⏰ 定期トレンド追跡（${interval}時間ごと）"
    echo "履歴保持数: ${max_history}件"
    echo ""
    echo "Cron設定例:"
    echo "0 */${interval} * * * ${SCRIPT_DIR}/track.sh keywords"
    echo ""
    echo "またはcronタブ設定:"
    echo "crontab -e"
    echo "0 */${interval} * * * ${SCRIPT_DIR}/track.sh keywords > /tmp/xai-track.log 2>&1"
}

# メイン処理
main() {
    local command="${1:-}"
    shift || true

    case "$command" in
        keywords)
            track_keywords "$@"
            ;;
        compare)
            compare_history "$@"
            ;;
        history)
            compare_history "${1:-10}"
            ;;
        cron)
            cron_track "$@"
            ;;
        *)
            cat << EOF
xAI トレンド追跡スクリプト

使用方法:
  $0 keywords [format]           # キーワードからトレンド検索
  $0 compare [count]              # 履歴比較（デフォルト5件）
  $0 history [count]              # 履歴一覧（デフォルト10件）
  $0 cron [interval] [max_history] # 定期実行設定表示

オプション:
  --format markdown|json        # 出力フォーマット指定

例:
  $0 keywords                    # キーワードトレンド検索（Markdown）
  $0 keywords --format json      # キーワードトレンド検索（JSON）
  $0 compare 10                  # 直近10件の履歴を比較
  $0 history 20                  # 直近20件の履歴を一覧
  $0 cron 3 30                   # 3時間ごと実行、履歴30件保持

ファイル:
  keywords.txt                  # トレンドキーワードリスト
  history/                       # 履歴データ保存先
EOF
            exit 1
            ;;
    esac
}

main "$@"
