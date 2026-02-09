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
# 1. X（Twitter）検索
# ============================================
echo "## 🐦 X（Twitter）検索" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# X認証情報の確認（環境変数: BIRD_AUTH_TOKEN, BIRD_CT0）
if [ -n "$BIRD_AUTH_TOKEN" ] && [ -n "$BIRD_CT0" ]; then
    KEYWORDS=("Clawdbot" "clawd skill" "clawdbot MCP" "#clawdbot")

    for keyword in "${KEYWORDS[@]}"; do
        echo "### 検索: $keyword" >> "$REPORT_FILE"
        
        # 過去24時間の投稿を検索（bird CLI使用）
        bird search "$keyword" -n 10 --json --auth-token "$BIRD_AUTH_TOKEN" --ct0 "$BIRD_CT0" 2>/dev/null | \
            jq -r '.tweets[]? | "- [\(.author.username)](\(.url)): \(.text | gsub("\n"; " "))"' \
            >> "$REPORT_FILE" 2>/dev/null || echo "  - 検索結果なし" >> "$REPORT_FILE"
        
        echo "" >> "$REPORT_FILE"
    done
else
    echo "- ⚠️ X認証情報が未設定（BIRD_AUTH_TOKEN, BIRD_CT0 環境変数が必要）" >> "$REPORT_FILE"
    echo "- GitHub/ClawdHubのリサーチのみ実行中" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# ============================================
# 2. ClawdHub - 新しいSkills
# ============================================
echo "## 🔧 ClawdHub - 新しいSkills" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# キーワード検索（memory, automation, notification など）
SKILL_KEYWORDS=("memory" "automation" "notification" "MCP" "productivity")

for skill_keyword in "${SKILL_KEYWORDS[@]}"; do
    echo "### カテゴリ: $skill_keyword" >> "$REPORT_FILE"
    clawdhub search "$skill_keyword" --limit 3 2>/dev/null | \
        awk '/^[a-z]/ {print "- **"$1"** "$2"\n  - "$3" "$4" "$5" "$6"\n"}' \
        >> "$REPORT_FILE" || echo "  - 検索結果なし" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
done

echo "" >> "$REPORT_FILE"

# ============================================
# 3. GitHub - MCPサーバー
# ============================================
echo "## 📦 GitHub - MCPサーバー" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v gh &> /dev/null; then
    gh search repos "MCP server" --limit 5 --json name,owner,description,url,stargazersCount,updatedAt 2>/dev/null | \
        jq -r '.[] | "- **\(.name)** by \(.owner.login) ⭐\(.stargazersCount)\n  - \(.description)\n  - URL: \(.url)\n  - 更新: \(.updatedAt)\n"' \
        >> "$REPORT_FILE" || echo "- GitHub検索エラー" >> "$REPORT_FILE"
else
    echo "- gh CLI未インストール" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"

# ============================================
# 4. GitHub - Clawdbot関連リポジトリ
# ============================================
echo "## 🐙 GitHub - Clawdbot関連" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if command -v gh &> /dev/null; then
    gh search repos "clawdbot" --limit 5 --json name,owner,description,url,stargazersCount,updatedAt 2>/dev/null | \
        jq -r '.[] | "- **\(.name)** by \(.owner.login) ⭐\(.stargazersCount)\n  - \(.description)\n  - URL: \(.url)\n  - 更新: \(.updatedAt)\n"' \
        >> "$REPORT_FILE" || echo "- GitHub検索エラー" >> "$REPORT_FILE"
else
    echo "- gh CLI未インストール" >> "$REPORT_FILE"
fi

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
# 6. 完了報告
# ============================================
echo "✅ リサーチ完了: $REPORT_FILE"
echo "📄 レポートを確認して Discord に投稿します"
