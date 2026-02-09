#!/bin/bash
# リサーチレポートをDiscordに自動投稿

set -e

TODAY=$(date +%Y-%m-%d)
REPORT_FILE="/root/clawd/research/$TODAY.md"
DISCORD_CHANNEL="1470296869870506156"  # #自己強化の間

if [ ! -f "$REPORT_FILE" ]; then
    echo "❌ レポートが見つかりません: $REPORT_FILE"
    exit 1
fi

# レポートを読み込んで整形
REPORT_CONTENT=$(cat "$REPORT_FILE")

# Discordメッセージフォーマット（2000文字制限対応）
MESSAGE="# 🔍 Clawdbot 自動リサーチレポート
**日付:** $TODAY

---

$(echo "$REPORT_CONTENT" | head -100)"

# clawdbot message send で投稿
clawdbot message send \
    --channel discord \
    --target "$DISCORD_CHANNEL" \
    --message "$MESSAGE"

echo "✅ Discord投稿完了: #自己強化の間"
