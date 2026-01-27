# HEARTBEAT.md - 自動タスク

## 自動バックアップ
- [ ] ワークスペースをGitHubにバックアップ（2時間ごと）

### バックアップ手順
1. `cd /root/clawd`
2. `git add -A`
3. `git commit -m "Auto backup: $(date '+%Y-%m-%d %H:%M')"`
4. `git push origin main`

### リポジトリ
- 本家: https://github.com/nick353/Nandemo-work-flow
- バックアップ: https://github.com/nick353/save-point
