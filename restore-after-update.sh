#!/bin/bash
# VPSアップデート後の復元スクリプト

set -e

WORKSPACE="/root/clawd"
CONFIG_BACKUP="$WORKSPACE/clawdbot-config.json"
CONFIG_TARGET="/root/.clawdbot/clawdbot.json"

echo "🔄 GitHubから最新の設定を取得中..."
cd "$WORKSPACE"
git pull

echo "📋 設定ファイルを復元中..."
if [ -f "$CONFIG_BACKUP" ]; then
    cp "$CONFIG_BACKUP" "$CONFIG_TARGET"
    echo "✅ 設定ファイルを復元しました"
else
    echo "❌ バックアップファイルが見つかりません"
    exit 1
fi

echo "🔄 Clawdbotを再起動中..."
clawdbot gateway restart || systemctl restart clawdbot

echo "✅ 復元完了！"
