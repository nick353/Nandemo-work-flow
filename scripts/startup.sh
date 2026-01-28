#!/bin/bash
# Clawdbot VPS起動時の自動復元スクリプト
# Zeaburの起動時に自動実行

set -e

echo "🚀 Clawdbot VPS起動処理を開始..."

BACKUP_DIR="/root/clawd/.clawdbot-backup"
CLAWDBOT_DIR="/root/.clawdbot"

# 1. 設定ファイルが存在しない場合、バックアップから復元
if [ ! -f "$CLAWDBOT_DIR/clawdbot.json" ]; then
  echo "⚠️  設定ファイルが見つかりません。バックアップから復元します..."
  
  if [ -d "$BACKUP_DIR/state" ]; then
    bash /root/clawd/scripts/restore-config.sh
  else
    echo "❌ バックアップが見つかりません。初回セットアップが必要です。"
    exit 1
  fi
else
  echo "✅ 設定ファイルが存在します"
fi

# 2. crontabが空の場合、バックアップから復元
if ! crontab -l 2>/dev/null | grep -q "backup-config.sh"; then
  echo "⚠️  crontabが設定されていません。バックアップから復元します..."
  
  if [ -f "$BACKUP_DIR/state/crontab.backup" ]; then
    crontab "$BACKUP_DIR/state/crontab.backup"
    echo "✅ crontab復元完了"
  else
    echo "ℹ️  crontabバックアップが見つかりません"
  fi
else
  echo "✅ crontabが設定されています"
fi

# 3. スクリプトに実行権限を付与
chmod +x /root/clawd/scripts/*.sh 2>/dev/null || true

echo ""
echo "✅ VPS起動処理完了！"
echo ""
echo "🚀 Gatewayを起動します..."

# 4. Gatewayを起動
exec clawdbot gateway start
