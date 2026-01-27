#!/bin/bash
# Git認証をセットアップ（手動実行用）
# 使い方: GITHUB_TOKEN=your_token ./setup-git-auth.sh

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ エラー: GITHUB_TOKEN環境変数が設定されていません"
    echo "使い方: GITHUB_TOKEN=your_token ./setup-git-auth.sh"
    exit 1
fi

cd /root/clawd

# リモートURLにトークンを含める（一時的）
git remote set-url origin "https://nick353:${GITHUB_TOKEN}@github.com/nick353/Nandemo-work-flow.git"
git remote set-url backup "https://nick353:${GITHUB_TOKEN}@github.com/nick353/save-point.git"

echo "✅ Git認証を設定しました"
echo "これで git push が動くようになります"
