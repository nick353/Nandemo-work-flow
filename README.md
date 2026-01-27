# Clawdbot Workspace - Nandemo-work-flow

このリポジトリはClawdbotのワークスペースです。

## 📁 構成

- **本家リポジトリ**: `https://github.com/nick353/Nandemo-work-flow` (origin)
- **バックアップ**: `https://github.com/nick353/save-point` (backup)

## 📋 ファイル

- `clawdbot-config.example.json` - 設定ファイルの例（機密情報なし）
- `auto-backup.sh` - 自動バックアップスクリプト
- `setup-git-auth.sh` - Git認証セットアップ
- `restore-after-update.sh` - VPSアップデート後の復元スクリプト
- ワークスペースファイル (AGENTS.md, SOUL.md, etc.)

⚠️ `clawdbot-config.json` は `.gitignore` で除外されています（機密情報保護のため）

## 🔧 使い方

### 初回セットアップ

```bash
cd /root/clawd
chmod +x final-clean-push.sh
GITHUB_TOKEN=<your_token_here> ./final-clean-push.sh
```

### バックアップを実行

**方法1: 毎回トークンを指定**
```bash
cd /root/clawd
GITHUB_TOKEN=<your_token> ./auto-backup.sh
```

**方法2: 認証を永続化してから実行**
```bash
cd /root/clawd
GITHUB_TOKEN=<your_token> ./setup-git-auth.sh
./auto-backup.sh  # 以降はトークン不要
```

### VPSアップデート後に復元

```bash
cd /root
git clone https://github.com/nick353/Nandemo-work-flow.git clawd
cd clawd
./restore-after-update.sh
```

## 🔐 セキュリティ

- Discordトークン、APIキーなどは `.gitignore` で除外
- GitHubトークンは環境変数経由で渡す（スクリプトには埋め込まない）
- `<your_token>` の部分は実際のトークンに置き換えてください

---

Last updated: 2026-01-27
