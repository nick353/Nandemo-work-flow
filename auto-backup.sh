#!/bin/bash
# 自動バックアップスクリプト - Clawdbot設定をGitHubに保存

set -e

WORKSPACE="/root/clawd"
CONFIG_SOURCE="/root/.clawdbot/clawdbot.json"
CONFIG_BACKUP="$WORKSPACE/clawdbot-config.json"

cd "$WORKSPACE"

# Git認証が設定されているか確認
if ! git remote get-url origin | grep -q "@github.com"; then
    if [ -z "$GITHUB_TOKEN" ]; then
        echo "❌ エラー: Git認証が未設定です"
        echo ""
        echo "以下のどちらかを実行してください:"
        echo "  1. GITHUB_TOKEN=your_token ./auto-backup.sh"
        echo "  2. GITHUB_TOKEN=your_token ./setup-git-auth.sh （永続設定）"
        exit 1
    fi
    
    # 一時的にトークンを設定
    git remote set-url origin "https://nick353:${GITHUB_TOKEN}@github.com/nick353/Nandemo-work-flow.git"
    git remote set-url backup "https://nick353:${GITHUB_TOKEN}@github.com/nick353/save-point.git"
fi

# 設定ファイルをコピー
echo "📋 設定ファイルをバックアップ中..."
cp "$CONFIG_SOURCE" "$CONFIG_BACKUP"

# Gitコミット
echo "💾 Gitにコミット中..."
git add .
git commit -m "Auto-backup: $(date '+%Y-%m-%d %H:%M:%S')" || echo "変更なし"

# 本家リポジトリにプッシュ
echo "🚀 本家リポジトリ (origin) にプッシュ中..."
git push origin master || git push origin main || echo "origin プッシュスキップ"

# バックアップリポジトリにプッシュ
echo "💾 バックアップリポジトリ (backup) にプッシュ中..."
git push backup master || git push backup main || echo "backup プッシュスキップ"

echo "✅ バックアップ完了！"
