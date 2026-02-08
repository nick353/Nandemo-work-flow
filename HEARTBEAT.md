# HEARTBEAT.md - 自動タスク

## 自動バックアップ
ハートビート時にGitHubバックアップを実行してください：

```bash
/root/clawd/scripts/backup-with-retry.sh
```

## ヘルスチェック
システムの安定性を確認します：

```bash
/root/clawd/scripts/health-check.sh
```

異常を検知した場合は、Discord（#sns-投稿）に報告してください。

### リポジトリ
- 本家: https://github.com/nick353/Nandemo-work-flow
- バックアップ: https://github.com/nick353/save-point

---

## VPSアップデート後の復元手順

### 自動復元されるもの（Zeaburボリューム）
- `/root/clawd` - ワークスペースファイル全部

### 手動復元が必要なもの
設定ファイルが消えた場合：
```bash
bash /root/clawd/scripts/restore-config.sh
```

### 設定バックアップ場所
- `/root/clawd/.clawdbot-backup/config-template.json` - 設定テンプレート（トークンなし）
- `/root/clawd/.clawdbot-backup/cron/` - cronジョブ

### トークン（別途保管が必要）
- Discord Bot Token: Zeabur環境変数 or Discord Developer Portal
- Anthropic API Key: Zeabur環境変数 or Anthropic Console
