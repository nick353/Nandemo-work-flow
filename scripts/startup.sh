#!/bin/bash
# Clawdbot VPS起動時の自動復元スクリプト
# Zeaburの起動時に自動実行

set -e

echo "🚀 Clawdbot VPS起動処理を開始..."

# Docker container path
BACKUP_DIR="/root/clawd/.clawdbot-backup"
CLAWDBOT_DIR="/root/.clawdbot"
RESTORE_SCRIPT="/app/scripts/restore-config.sh"

# 1. 設定ファイルが存在しない場合、バックアップから復元
if [ ! -f "$CLAWDBOT_DIR/clawdbot.json" ]; then
  echo "⚠️  設定ファイルが見つかりません。バックアップから復元します..."

  if [ -d "$BACKUP_DIR/state" ] && [ -f "$RESTORE_SCRIPT" ]; then
    bash "$RESTORE_SCRIPT"
  else
    echo "ℹ️  バックアップまたは復元スクリプトが見つかりません。"
    echo "ℹ️  初回起動またはバックアップ未作成の状態です。"
  fi
else
  echo "✅ 設定ファイルが存在します"
fi

# 2. crontabが空の場合、バックアップから復元
if ! crontab -l 2>/dev/null | grep -q "backup-config.sh"; then
  echo "ℹ️  crontabが設定されていません（初回起動時は正常）"

  if [ -f "$BACKUP_DIR/state/crontab.backup" ]; then
    crontab "$BACKUP_DIR/state/crontab.backup"
    echo "✅ crontab復元完了"
  fi
else
  echo "✅ crontabが設定されています"
fi

# 3. スクリプトに実行権限を付与
chmod +x /app/scripts/*.sh 2>/dev/null || true

echo ""
echo "✅ VPS起動処理完了！"
echo ""
