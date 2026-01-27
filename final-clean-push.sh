#!/bin/bash
# 完全クリーンな履歴でプッシュ（最終版）

set -e

cd /root/clawd

echo "🧹 完全にクリーンな履歴を作成中..."

# 1. .gitを完全削除
rm -rf .git

# 2. Gitを初期化
git init
git config user.name "nick353"
git config user.email "nichika2000823@gmail.com"

# 3. リモートを追加（トークンは環境変数から）
if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ エラー: GITHUB_TOKEN環境変数が必要です"
    echo "実行方法: GITHUB_TOKEN=your_token ./final-clean-push.sh"
    exit 1
fi

git remote add origin "https://nick353:${GITHUB_TOKEN}@github.com/nick353/Nandemo-work-flow.git"
git remote add backup "https://nick353:${GITHUB_TOKEN}@github.com/nick353/save-point.git"

# 4. 全ファイルをコミット（.gitignoreで自動除外される）
echo "📝 ファイルをコミット中..."
git add .
git commit -m "Initial clean setup: Workspace without sensitive data"

# 5. 強制プッシュ（履歴を完全に上書き）
echo "🚀 本家リポジトリに強制プッシュ中..."
git push -f origin master

echo "💾 バックアップリポジトリに強制プッシュ中..."
git push -f backup master

echo ""
echo "✅ 完了！セットアップ成功 🎉"
echo ""
echo "今後のバックアップ:"
echo "  cd /root/clawd"
echo "  GITHUB_TOKEN=your_token ./auto-backup.sh"
echo ""
echo "または、リモートURLを永続的に設定:"
echo "  GITHUB_TOKEN=your_token ./setup-git-auth.sh"
