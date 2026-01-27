# HEARTBEAT.md - 自動タスク

## 自動バックアップ
- [x] ワークスペースをGitHubにバックアップ（2時間ごと）- cronジョブ設定済み

### バックアップ手順
1. `cd /root/clawd`
2. `git add -A`
3. `git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M')"`
4. `git push origin main`

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
