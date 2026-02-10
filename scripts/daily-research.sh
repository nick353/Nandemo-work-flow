#!/bin/bash
# Clawdbot話題性リサーチ v3（簡略化版）
# 前日の話題になったツール・MCPを厳選5件

set -e

TODAY=$(date +%Y-%m-%d)
RESEARCH_DIR="/root/clawd/research"
REPORT_FILE="$RESEARCH_DIR/$TODAY.md"

mkdir -p "$RESEARCH_DIR"

echo "🔍 話題性リサーチ開始: $TODAY"

# ============================================
# 1. GitHub検索（⭐500以上、最新順）
# ============================================
echo "## 🐙 GitHub検索（⭐500以上）..."

GITHUB_JSON=$(gh search repos "MCP server stars:>=500" --sort updated --limit 10 \
    --json name,owner,description,stargazersCount,url,updatedAt 2>/dev/null || echo "[]")

echo "$GITHUB_JSON" | jq -r '.[] | "  ⭐\(.stargazersCount) \(.name)"' | head -5

# ============================================
# 2. X言及数カウント（各ツール名で検索）
# ============================================
echo "## 🐦 X言及数カウント..."

# X認証確認
if [ -z "$AUTH_TOKEN" ] || [ -z "$CT0" ]; then
    echo "⚠️ X認証未設定（GitHub⭐数のみで判定）"
    X_ENABLED=false
else
    X_ENABLED=true
fi

# トップ15のツール名を抽出（5件選出のため余裕を持たせる）
TOOL_NAMES=$(echo "$GITHUB_JSON" | jq -r '.[0:15] | .[].name' | tr '\n' ' ')

# 各ツールのX言及数をカウント
declare -A MENTION_COUNT

if [ "$X_ENABLED" = true ]; then
    for tool in $TOOL_NAMES; do
        echo "  検索中: $tool"
        
        # ツール名で検索（過去24時間）
        COUNT=$(bird search "$tool" -n 50 --json --auth-token "$AUTH_TOKEN" --ct0 "$CT0" 2>/dev/null | \
            jq 'length' 2>/dev/null || echo "0")
        
        MENTION_COUNT["$tool"]=$COUNT
        echo "    → $COUNT 件"
    done
fi

# ============================================
# 3. スコア計算＆トップ5選出
# ============================================
echo "## 🔥 スコア計算..."

# GitHub JSONにX言及数を追加してトップ5を選出
TOP5_JSON=$(echo "$GITHUB_JSON" | jq --argjson x_enabled "$X_ENABLED" '
    map(
        . + {
            x_mentions: 0,
            score: .stargazersCount
        }
    ) | 
    sort_by(-.score) | 
    .[0:5]
')

# X言及数を追加（bashの連想配列から）
if [ "$X_ENABLED" = true ]; then
    for tool in $TOOL_NAMES; do
        mentions=${MENTION_COUNT[$tool]:-0}
        if [ "$mentions" -gt 0 ]; then
            TOP5_JSON=$(echo "$TOP5_JSON" | jq --arg name "$tool" --argjson mentions "$mentions" '
                map(if .name == $name then .x_mentions = $mentions | .score = (.stargazersCount + ($mentions * 100)) else . end)
            ')
        fi
    done
    
    # 再ソート
    TOP5_JSON=$(echo "$TOP5_JSON" | jq 'sort_by(-.score) | .[0:5]')
fi

echo "トップ5:"
echo "$TOP5_JSON" | jq -r '.[] | "  🔥 \(.name) (⭐\(.stargazersCount), X言及:\(.x_mentions)件, スコア:\(.score))"'

# ============================================
# 4. レポート生成
# ============================================
echo "## 📝 レポート生成中..."

cat > "$REPORT_FILE" << 'HEADER'
# 🔥 今日の話題（前日の注目ツール）

HEADER

echo "**生成日:** $TODAY" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "前日に話題になったMCPサーバー・ツールを厳選5件ピックアップっぴ！ 🦜" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# トップ5を詳細表示
COUNTER=1
echo "$TOP5_JSON" | jq -c '.[]' | while read -r item; do
    NAME=$(echo "$item" | jq -r '.name')
    OWNER=$(echo "$item" | jq -r '.owner.login')
    STARS=$(echo "$item" | jq -r '.stargazersCount')
    DESC=$(echo "$item" | jq -r '.description // "説明なし"')
    URL=$(echo "$item" | jq -r '.url')
    MENTIONS=$(echo "$item" | jq -r '.x_mentions')
    SCORE=$(echo "$item" | jq -r '.score')
    
    # 話題度判定
    if [ "$MENTIONS" -ge 3 ]; then
        TREND="🔥 話題度: 高（X言及 ${MENTIONS}件）"
    elif [ "$MENTIONS" -gt 0 ]; then
        TREND="📊 注目度: 中（X言及 ${MENTIONS}件）"
    else
        TREND="📊 注目度: 中（GitHub⭐のみ）"
    fi
    
    # このClawdbotに追加するとどうなるかを生成
    CLAWDBOT_IMPACT=""
    case "$NAME" in
        *"fastmcp"*|*"fast-mcp"*)
            CLAWDBOT_IMPACT="Pythonスクリプトを書くだけで、新しいMCPサーバーを簡単に追加できるようになる。現在手動でやっている作業が大幅に効率化される"
            ;;
        *"activepieces"*)
            CLAWDBOT_IMPACT="複数のツールを連携させた自動化が可能に。例: 毎朝のリサーチ結果をSlack/Discord/Notionに同時投稿、といった連携が簡単に設定できる"
            ;;
        *"genai-toolbox"*|*"mcp-toolbox"*)
            CLAWDBOT_IMPACT="データベースへの自然言語クエリが可能に。「昨日のリサーチ結果を検索して」といった指示でデータベースを直接操作できる"
            ;;
        *"playwright"*|*"browser"*)
            CLAWDBOT_IMPACT="ブラウザ操作がより高度に。JavaScript実行、スクリーンショット、PDF生成など、より複雑なWeb自動化が可能になる"
            ;;
        *"github"*|*"git"*)
            CLAWDBOT_IMPACT="GitHubの操作が自動化可能に。「このリポジトリの最新コミットを確認」「PRを作成」といった操作がチャットから直接できる"
            ;;
        *"slack"*|*"discord"*|*"telegram"*)
            CLAWDBOT_IMPACT="複数のメッセージングサービスを統合管理。1つのインターフェースから複数のチャットツールを操作できるようになる"
            ;;
        *"notion"*|*"obsidian"*)
            CLAWDBOT_IMPACT="ノート・ドキュメント管理が統合される。リサーチ結果やメモを自動でNotionに整理・保存できる"
            ;;
        *"calendar"*|*"schedule"*)
            CLAWDBOT_IMPACT="スケジュール管理を完全自動化。「明日の予定は？」「来週の会議を予約」といった操作がチャットから可能に"
            ;;
        *"weather"*)
            CLAWDBOT_IMPACT="天気情報を自動取得。「今日の天気は？」「明日傘いる？」といった質問にリアルタイムで回答できる"
            ;;
        *"mail"*|*"email"*)
            CLAWDBOT_IMPACT="メール操作を自動化。「未読メールを要約して」「重要なメールに返信」といった操作がAIから可能に"
            ;;
        *)
            CLAWDBOT_IMPACT="$DESC"
            ;;
    esac
    
    cat >> "$REPORT_FILE" << ITEM

## $COUNTER. **$NAME** by $OWNER

**⭐ $STARS** | $TREND | スコア: $SCORE

**このClawdbotに追加すると:**  
$CLAWDBOT_IMPACT

ITEM
    
    # X言及があれば抜粋表示
    if [ "$X_ENABLED" = true ] && [ "$MENTIONS" -gt 0 ]; then
        echo "**Xでの反応:**" >> "$REPORT_FILE"
        bird search "$NAME" -n 3 --json --auth-token "$AUTH_TOKEN" --ct0 "$CT0" 2>/dev/null | \
            jq -r '.[0:3] | .[] | "- @\(.author.username): \"\(.text | gsub("\n"; " ") | .[0:100])...\"" ' \
            >> "$REPORT_FILE" 2>/dev/null || echo "- （データ取得失敗）" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
    
    cat >> "$REPORT_FILE" << FOOTER
**GitHub:** $URL

**💬 やってみますか？**

---

FOOTER
    
    COUNTER=$((COUNTER + 1))
done

echo "" >> "$REPORT_FILE"
echo "📄 **詳細レポート:** \`$REPORT_FILE\`" >> "$REPORT_FILE"

echo "✅ レポート生成完了: $REPORT_FILE"

# ============================================
# 5. 強制Discord通知（完了報告）
# ============================================
DISCORD_CHANNEL_ID="${RESEARCH_DISCORD_CHANNEL:-1470296869870506156}"

echo ""
echo "📢 Discord通知を送信中..."

SUMMARY="# 🐥 毎朝リサーチ完了！

**日付:** $TODAY

✅ 話題のツール5件を厳選しました！

📄 詳細レポート: \`research/$TODAY.md\`

各ツールについて「このClawdbotに追加するとどうなるか」も記載してあるっぴ🐥
"

# Discord通知（失敗してもエラーにしない）
if command -v clawdbot &> /dev/null; then
    if clawdbot message send --target "$DISCORD_CHANNEL_ID" --message "$SUMMARY" 2>/dev/null; then
        echo "✅ Discord通知完了"
    else
        echo "⚠️ Discord通知失敗（手動確認が必要）"
    fi
else
    echo "⚠️ clawdbot コマンドが見つかりません"
fi

echo ""
echo "🐥 全工程完了！"
