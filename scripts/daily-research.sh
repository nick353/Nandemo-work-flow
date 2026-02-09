#!/bin/bash
# Clawdbot自己成長型リサーチシステム
# 毎朝、最新のSkills・MCP・Tips・事例を収集して報告

set -e

TODAY=$(date +%Y-%m-%d)
RESEARCH_DIR="/root/clawd/research"
REPORT_FILE="$RESEARCH_DIR/$TODAY.md"

mkdir -p "$RESEARCH_DIR"

echo "🔍 Clawdbotリサーチ開始: $TODAY"

# ============================================
# 1. X（Twitter）検索 【メイン】
# ============================================
echo "## 🐦 X（Twitter）最新情報" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# X認証情報の確認（環境変数: AUTH_TOKEN, CT0）
if [ -n "$AUTH_TOKEN" ] && [ -n "$CT0" ]; then
    # より幅広いキーワードで検索（Skills、MCP、Tips、事例、自動化）
    KEYWORDS=("Clawdbot" "MCP server" "MCP" "automation tool" "AI automation" "workflow automation" "clawdbot skill" "#clawdbot")

    for keyword in "${KEYWORDS[@]}"; do
        echo "### 🔍 $keyword" >> "$REPORT_FILE"
        
        # 検索数を20件に増やして最新情報をキャッチ
        bird search "$keyword" -n 20 --json --auth-token "$AUTH_TOKEN" --ct0 "$CT0" 2>/dev/null | \
            jq -r '.tweets[]? | "- **[@\(.author.username)](\(.url))** (\(.createdAt | split("T")[0]))\n  > \(.text | gsub("\n"; " ") | .[0:200])...\n"' \
            >> "$REPORT_FILE" 2>/dev/null || echo "  - 検索結果なし\n" >> "$REPORT_FILE"
        
        echo "" >> "$REPORT_FILE"
    done
else
    echo "- ⚠️ X認証情報が未設定（AUTH_TOKEN, CT0 環境変数が必要）" >> "$REPORT_FILE"
    echo "- GitHubのリサーチのみ実行中" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# ============================================
# 2. GitHub - 最新リポジトリ 【メイン】
# ============================================
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## 🐙 GitHub - 最新MCPサーバー＆Clawdbot関連" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v gh &> /dev/null; then
    # MCPサーバー（最新順、10件）
    echo "### 📦 MCPサーバー" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    gh search repos "MCP server" --sort updated --limit 10 --json name,owner,description,url,stargazersCount,updatedAt 2>/dev/null | \
        jq -r '.[] | "- **\(.name)** by \(.owner.login) ⭐\(.stargazersCount)\n  - \(.description // "説明なし")\n  - \(.url)\n  - 更新: \(.updatedAt | split("T")[0])\n"' \
        >> "$REPORT_FILE" || echo "- GitHub検索エラー\n" >> "$REPORT_FILE"
    
    echo "" >> "$REPORT_FILE"
    
    # Clawdbot関連（最新順、10件）
    echo "### 🦜 Clawdbot関連" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    gh search repos "clawdbot OR clawd" --sort updated --limit 10 --json name,owner,description,url,stargazersCount,updatedAt 2>/dev/null | \
        jq -r '.[] | "- **\(.name)** by \(.owner.login) ⭐\(.stargazersCount)\n  - \(.description // "説明なし")\n  - \(.url)\n  - 更新: \(.updatedAt | split("T")[0])\n"' \
        >> "$REPORT_FILE" || echo "- GitHub検索エラー\n" >> "$REPORT_FILE"
    
    echo "" >> "$REPORT_FILE"
    
    # AI Agent Skills（最新順、10件）
    echo "### 🤖 AI Agent Skills" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    gh search repos "AI agent skill OR claude skill" --sort updated --limit 10 --json name,owner,description,url,stargazersCount,updatedAt 2>/dev/null | \
        jq -r '.[] | "- **\(.name)** by \(.owner.login) ⭐\(.stargazersCount)\n  - \(.description // "説明なし")\n  - \(.url)\n  - 更新: \(.updatedAt | split("T")[0])\n"' \
        >> "$REPORT_FILE" || echo "- GitHub検索エラー\n" >> "$REPORT_FILE"
else
    echo "- gh CLI未インストール" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# ============================================
# 3. ClawdHub - 補足情報
# ============================================
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## 🔧 ClawdHub（補足）" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 厳選キーワードのみ（軽量化）
SKILL_KEYWORDS=("memory" "MCP" "automation")

for skill_keyword in "${SKILL_KEYWORDS[@]}"; do
    echo "### $skill_keyword" >> "$REPORT_FILE"
    clawdhub search "$skill_keyword" --limit 2 2>/dev/null | \
        awk '/^[a-z]/ {print "- **"$1"**"}' \
        >> "$REPORT_FILE" || echo "  - 検索結果なし" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"

# ============================================
# 5. サマリー生成（重要度分類）
# ============================================
echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "## 📊 重要度分類" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🔴 高優先度（必須）" >> "$REPORT_FILE"
echo "- （手動レビュー後に追加）" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🟡 中優先度（推奨）" >> "$REPORT_FILE"
echo "- （手動レビュー後に追加）" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🟢 低優先度（オプション）" >> "$REPORT_FILE"
echo "- （手動レビュー後に追加）" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# ============================================
# 6. Discord投稿（別チャンネル）
# ============================================
DISCORD_CHANNEL_ID="${RESEARCH_DISCORD_CHANNEL:-1470296869870506156}"

if [ -f "$REPORT_FILE" ]; then
    echo "✅ リサーチ完了: $REPORT_FILE"
    echo "📤 Discord (#自己強化の間) に投稿中..."
    
    # レポート内容をDiscordに投稿
    clawdbot message send --target "$DISCORD_CHANNEL_ID" --message "$(cat "$REPORT_FILE")" 2>/dev/null || {
        echo "⚠️ Discord投稿失敗（手動で確認してください）"
    }
    
    echo "✅ 投稿完了"
else
    echo "❌ レポートファイルが見つかりません: $REPORT_FILE"
fi
