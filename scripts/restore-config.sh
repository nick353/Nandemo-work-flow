#!/bin/bash
# Clawdbot設定復元スクリプト
# VPSアップデート後に実行してください

BACKUP_DIR="/root/clawd/.clawdbot-backup"
TARGET_DIR="$HOME/.clawdbot"

if [ -d "$BACKUP_DIR" ]; then
    echo "📦 バックアップから設定を復元中..."
    mkdir -p "$TARGET_DIR"
    cp -r "$BACKUP_DIR/clawdbot.json" "$TARGET_DIR/" 2>/dev/null && echo "✅ clawdbot.json 復元完了"
    cp -r "$BACKUP_DIR/cron" "$TARGET_DIR/" 2>/dev/null && echo "✅ cron 復元完了"
    echo "🎉 復元完了！Clawdbotを再起動してください。"
else
    echo "❌ バックアップが見つかりません: $BACKUP_DIR"
    exit 1
fi
