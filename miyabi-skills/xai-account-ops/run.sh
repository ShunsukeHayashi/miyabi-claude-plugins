#!/usr/bin/env bash
set -euo pipefail

# xAI Account Operations スキル実行スクリプト
# 使用方法: ./run.sh [analyze|trend|competitor|suggest] [args...] [--format markdown|json]

# 環境変数読み込み
if [ -f "$HOME/.config/claude-env/tokens.conf" ]; then
    source "$HOME/.config/claude-env/tokens.conf"
fi

# API設定
API_BASE="https://api.x.ai/v1"
MODEL="grok-4-fast"
OUTPUT_DIR="$HOME/.claude/skills/xai-account-ops/outputs"
REPORT_DIR="$HOME/.claude/skills/xai-account-ops/reports"
mkdir -p "$OUTPUT_DIR" "$REPORT_DIR"

# デフォルトフォーマット
OUTPUT_FORMAT="${OUTPUT_FORMAT:-markdown}"

# 関数定義
usage() {
    cat << EOF
xAI Account Operations スキル

使用方法:
  $0 analyze <handle>           # アカウント分析
  $0 trend <keyword>            # トレンド検索
  $0 competitor <handles>       # 競合分析 (カンマ区切り)
  $0 suggest <handle>           # 改善提案

オプション:
  --format markdown|json        # 出力フォーマット指定

例:
  $0 analyze The_AGI_WAY
  $0 analyze The_AGI_WAY --format markdown
  $0 trend "Claude Code"
  $0 competitor "satori_sz9,ai_and_and"
  $0 suggest The_AGI_WAY
EOF
    exit 1
}

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

# Markdownレポート生成
generate_markdown_report() {
    local output_type="$1"
    local handle="$2"
    local content="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local report_file="${REPORT_DIR}/${output_type}_${handle}_$(date +%Y%m%d_%H%M%S).md"

    cat > "$report_file" << EOF
# @${handle} ${output_type} レポート

**生成日時**: ${timestamp}
**分析対象**: https://x.com/${handle}

---

## 分析結果

${content}

---

*本レポートは xAI API (Grok-4) によって生成されました*
EOF

    echo "$report_file"
}

# JSONレポート生成
generate_json_report() {
    local output_type="$1"
    local handle="$2"
    local raw_json="$3"
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    local report_file="${REPORT_DIR}/${output_type}_${handle}_$(date +%Y%m%d_%H%M%S).json"

    cat > "$report_file" << EOF
{
  "report_type": "${output_type}",
  "handle": "${handle}",
  "generated_at": "${timestamp}",
  "api_model": "${MODEL}",
  "raw_response": ${raw_json}
}
EOF

    echo "$report_file"
}

# アカウント分析
analyze_account() {
    local handle="$1"
    local format="$2"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="${OUTPUT_DIR}/analyze_${handle}_${timestamp}.json"

    echo "📊 アカウント分析中: @${handle}"

    local prompt="@${handle}の最新投稿10件を分析してください。以下の点について教えてください：
1. エンゲージメントが高い投稿の特徴
2. 投稿トピックの傾向
3. 最適な投稿時間
4. 改善提案"

    local tools='{"type":"x_search","x_search":{"allowed_x_handles":["'"${handle}"'"]}}'

    local response=$(call_xai "$prompt" "$tools")
    echo "$response" > "$output_file"

    local content=$(echo "$response" | jq -r '.output[1].content[0].text // .output[0].content[0].text // empty')

    if [ "$format" = "json" ]; then
        local report_file=$(generate_json_report "analyze" "$handle" "$(echo "$response" | jq -c '.')")
        echo ""
        echo "📄 JSONレポート: $report_file"
    else
        local report_file=$(generate_markdown_report "アカウント分析" "$handle" "$content")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$report_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📄 Markdownレポート: $report_file"
    fi

    echo "✅ 生データ保存: $output_file"
}

# トレンド検索
search_trend() {
    local keyword="$1"
    local from_date="${2:-}"
    local to_date="${3:-}"
    local format="${4:-markdown}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="${OUTPUT_DIR}/trend_${timestamp}.json"

    echo "🔍 トレンド検索中: ${keyword}"

    local prompt="「${keyword}」について今バズっている日本語投稿TOP5を教えて。エンゲージメント数、投稿内容、傾向を分析してください。"

    local tools='{"type":"x_search"}'

    if [ -n "$from_date" ] && [ -n "$to_date" ]; then
        tools='{"type":"x_search","x_search":{"from_date":"'"${from_date}"'","to_date":"'"${to_date}"'"}}'
    fi

    local response=$(call_xai "$prompt" "$tools")
    echo "$response" > "$output_file"

    local content=$(echo "$response" | jq -r '.output[1].content[0].text // .output[0].content[0].text // empty')

    if [ "$format" = "json" ]; then
        local report_file=$(generate_json_report "trend" "$keyword" "$(echo "$response" | jq -c '.')")
        echo ""
        echo "📄 JSONレポート: $report_file"
    else
        local report_file=$(generate_markdown_report "トレンド分析" "$keyword" "$content")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$report_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📄 Markdownレポート: $report_file"
    fi

    echo "✅ 生データ保存: $output_file"
}

# 競合分析
analyze_competitor() {
    local handles="$1"
    local format="${2:-markdown}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="${OUTPUT_DIR}/competitor_${timestamp}.json"

    echo "🎯 競合分析中: ${handles}"

    local prompt="以下のアカウントの最新投稿でバズっているものを比較分析してください：${handles}"

    local handles_array=$(echo "$handles" | jq -R 'split(",") | map(.[:-1]) | . as $handles | {type:"x_search",x_search:{allowed_x_handles:$handles}}')

    local response=$(call_xai "$prompt" "$handles_array")
    echo "$response" > "$output_file"

    local content=$(echo "$response" | jq -r '.output[0].content[0].text // .output[0].message.content // empty')

    if [ "$format" = "json" ]; then
        local report_file=$(generate_json_report "competitor" "$handles" "$(echo "$response" | jq -c '.')")
        echo ""
        echo "📄 JSONレポート: $report_file"
    else
        local report_file=$(generate_markdown_report "競合分析" "$handles" "$content")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$report_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📄 Markdownレポート: $report_file"
    fi

    echo "✅ 生データ保存: $output_file"
}

# 改善提案
suggest_improvement() {
    local handle="$1"
    local format="${2:-markdown}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="${OUTPUT_DIR}/suggest_${handle}_${timestamp}.json"

    echo "💡 改善提案生成中: @${handle}"

    local prompt="@${handle}のアカウント運用について、データに基づく具体的な改善提案をしてください。以下を含めてください：
1. コンテンツ戦略
2. 投稿タイミング
3. エンゲージメント向上策
4. フォロワー増加策"

    local tools='{"type":"x_search","x_search":{"allowed_x_handles":["'"${handle}"'"]}}'

    local response=$(call_xai "$prompt" "$tools")
    echo "$response" > "$output_file"

    local content=$(echo "$response" | jq -r '.output[1].content[0].text // .output[0].content[0].text // empty')

    if [ "$format" = "json" ]; then
        local report_file=$(generate_json_report "suggest" "$handle" "$(echo "$response" | jq -c '.')")
        echo ""
        echo "📄 JSONレポート: $report_file"
    else
        local report_file=$(generate_markdown_report "改善提案" "$handle" "$content")
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$report_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "📄 Markdownレポート: $report_file"
    fi

    echo "✅ 生データ保存: $output_file"
}

# メイン処理
main() {
    local command="${1:-}"
    shift || true
    local format="markdown"

    # オプション解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --format)
                format="$2"
                shift 2
                ;;
            *)
                break
                ;;
        esac
    done

    case "$command" in
        analyze)
            [ -z "${1:-}" ] && { echo "エラー: ハンドルを指定してください"; usage; }
            analyze_account "$1" "$format"
            ;;
        trend)
            [ -z "${1:-}" ] && { echo "エラー: キーワードを指定してください"; usage; }
            search_trend "$1" "${2:-}" "${3:-}" "$format"
            ;;
        competitor)
            [ -z "${1:-}" ] && { echo "エラー: ハンドルを指定してください（カンマ区切り）"; usage; }
            analyze_competitor "$1" "$format"
            ;;
        suggest)
            [ -z "${1:-}" ] && { echo "エラー: ハンドルを指定してください"; usage; }
            suggest_improvement "$1" "$format"
            ;;
        *)
            usage
            ;;
    esac
}

main "$@"
