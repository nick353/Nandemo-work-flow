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
# 1. GitHub検索（⭐500以上、複数キーワード）
# ============================================
echo "## 🐙 GitHub検索（⭐500以上、幅広く検索）..."

# 複数キーワードで検索
SEARCH_KEYWORDS=(
    "MCP server"
    "AI agent"
    "AI automation"
    "agent skill"
    "automation tool"
    "LLM tool"
)

GITHUB_JSON="[]"

for keyword in "${SEARCH_KEYWORDS[@]}"; do
    echo "  検索中: $keyword"
    
    # 各キーワードで検索（⭐500以上、最新順、3件）
    RESULT=$(gh search repos "$keyword stars:>=500" --sort updated --limit 3 \
        --json name,owner,description,stargazersCount,url,updatedAt 2>/dev/null || echo "[]")
    
    # 結果をマージ
    GITHUB_JSON=$(echo "$GITHUB_JSON" "$RESULT" | jq -s '.[0] + .[1]')
done

# 重複を削除してスター数でソート
GITHUB_JSON=$(echo "$GITHUB_JSON" | jq 'unique_by(.name) | sort_by(-.stargazersCount) | .[0:15]')

echo ""
echo "検索結果（重複削除後、トップ10）:"
echo "$GITHUB_JSON" | jq -r '.[] | "  ⭐\(.stargazersCount) \(.name)"' | head -10

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

**どうなる？**  
$CLAWDBOT_IMPACT

**GitHub:** $URL

ITEM
    
    # X言及があれば抜粋表示
    if [ "$X_ENABLED" = true ] && [ "$MENTIONS" -gt 0 ]; then
        echo "**Xでの反応:**" >> "$REPORT_FILE"
        bird search "$NAME" -n 3 --json --auth-token "$AUTH_TOKEN" --ct0 "$CT0" 2>/dev/null | \
            jq -r '.[0:3] | .[] | "- @\(.author.username): \"\(.text | gsub("\n"; " ") | .[0:100])...\"" ' \
            >> "$REPORT_FILE" 2>/dev/null || echo "- （データ取得失敗）" >> "$REPORT_FILE"
        echo "" >> "$REPORT_FILE"
    fi
    
    # 参考URLを追加（公式ドキュメント・デモサイトなど）
    echo "**参考URL:**" >> "$REPORT_FILE"
    
    # よく知られたツールの公式リンクを追加
    case "$NAME" in
        *"fastmcp"*)
            echo "- 📖 ドキュメント: https://fastmcp.dev" >> "$REPORT_FILE"
            ;;
        *"activepieces"*)
            echo "- 📖 ドキュメント: https://www.activepieces.com/docs" >> "$REPORT_FILE"
            echo "- 🎮 デモ: https://cloud.activepieces.com" >> "$REPORT_FILE"
            ;;
        *"genai-toolbox"*)
            echo "- 📖 ドキュメント: https://googleapis.github.io/genai-toolbox/" >> "$REPORT_FILE"
            ;;
        *"playwright"*)
            echo "- 📖 ドキュメント: https://playwright.dev" >> "$REPORT_FILE"
            ;;
        *"github"*)
            echo "- 📖 GitHub MCP: https://github.com/modelcontextprotocol" >> "$REPORT_FILE"
            ;;
        *)
            # GitHubのREADMEリンク
            echo "- 📖 README: $URL#readme" >> "$REPORT_FILE"
            ;;
    esac
    
    cat >> "$REPORT_FILE" << FOOTER

**💬 やってみますか？**

---

FOOTER
    
    COUNTER=$((COUNTER + 1))
done

echo "" >> "$REPORT_FILE"
echo "📄 **詳細レポート:** \`$REPORT_FILE\`" >> "$REPORT_FILE"

echo "✅ レポート生成完了: $REPORT_FILE"

# ============================================
# 5. Discord投稿用の要約版を生成
# ============================================
DISCORD_FILE="$TEMP_DIR/discord_post.md"

cat > "$DISCORD_FILE" << 'HEADER'
# 🔥 今日の話題（前日の注目ツール）

前日に話題になったMCPサーバー・ツールを厳選5件ピックアップっぴ！ 🦜

---

HEADER

# トップ5をDiscord投稿用にフォーマット
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
    else
        TREND="📊 注目度: 中"
    fi
    
    # どうなる？を生成
    CLAWDBOT_IMPACT=""
    case "$NAME" in
        *"context7"*)
            CLAWDBOT_IMPACT="最新コードドキュメントをLLMとAIエディタに自動提供。コード補完・提案の精度が劇的に向上"
            ;;
        *"fastmcp"*|*"fast-mcp"*)
            CLAWDBOT_IMPACT="Pythonスクリプトを書くだけで新しいMCPサーバーを簡単に追加できる。手動作業が大幅効率化"
            ;;
        *"activepieces"*)
            CLAWDBOT_IMPACT="複数ツール連携自動化が可能に。例: リサーチ結果→Slack/Discord/Notionに同時投稿"
            ;;
        *"genai-toolbox"*|*"mcp-toolbox"*)
            CLAWDBOT_IMPACT="データベースへの自然言語クエリが可能に。「昨日のリサーチ結果を検索して」でDB直接操作"
            ;;
        *"kreuzberg"*)
            CLAWDBOT_IMPACT="PDF/Office/画像など75種類以上の文書から自動でテキスト・メタデータ抽出。議事録→要約、請求書OCR→DB化が可能に"
            ;;
        *"playwright"*|*"browser"*)
            CLAWDBOT_IMPACT="ブラウザ操作がより高度に。JavaScript実行、スクリーンショット、PDF生成など複雑なWeb自動化が可能"
            ;;
        *"github"*|*"git"*)
            CLAWDBOT_IMPACT="GitHubの操作が自動化可能に。「このリポジトリの最新コミットを確認」「PRを作成」がチャットから直接できる"
            ;;
        *)
            CLAWDBOT_IMPACT="$DESC"
            ;;
    esac
    
    cat >> "$DISCORD_FILE" << ITEM

## $COUNTER. **$NAME** by $OWNER

**⭐ $(printf "%'d" $STARS)** | $TREND

**どうなる？**  
$CLAWDBOT_IMPACT

ITEM
    
    # X言及があれば抜粋表示（2件のみ、短縮版）
    if [ "$X_ENABLED" = true ] && [ "$MENTIONS" -gt 0 ]; then
        echo "**Xでの声:**" >> "$DISCORD_FILE"
        bird search "$NAME" -n 2 --json --auth-token "$AUTH_TOKEN" --ct0 "$CT0" 2>/dev/null | \
            jq -r '.[0:2] | .[] | "- @\(.author.username): \"\(.text | gsub("\n"; " ") | .[0:80])...\"" ' \
            >> "$DISCORD_FILE" 2>/dev/null || echo "- （取得失敗）" >> "$DISCORD_FILE"
        echo "" >> "$DISCORD_FILE"
    fi
    
    # 参考URLを追加
    echo "**参考URL:** $URL" >> "$DISCORD_FILE"
    
    cat >> "$DISCORD_FILE" << FOOTER

**💬 やってみますか？**

---

FOOTER
    
    COUNTER=$((COUNTER + 1))
done

echo "" >> "$DISCORD_FILE"
echo "📄 詳細: \`$REPORT_FILE\`" >> "$DISCORD_FILE"

echo "📤 Discord投稿用ファイル生成完了: $DISCORD_FILE"

# ============================================
# 6. Discord投稿フラグ作成
# ============================================
DISCORD_PENDING_FLAG="/root/clawd/.discord_post_pending"

echo ""
echo "📢 Discord投稿準備中..."

# Discord投稿待ちフラグを作成（ハートビート時に検知される）
echo "$TODAY" > "$DISCORD_PENDING_FLAG"
echo "$REPORT_FILE" >> "$DISCORD_PENDING_FLAG"
echo "1470296869870506156" >> "$DISCORD_PENDING_FLAG"  # チャンネルID

echo "✅ Discord投稿フラグ作成完了"
echo "📍 次回ハートビート時に自動投稿されます"
echo ""
echo "🐥 リサーチ完了！"
