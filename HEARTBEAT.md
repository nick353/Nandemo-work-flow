# HEARTBEAT.md - 自動タスク

## 1. 実行中タスクのチェック（最優先）
**必ず最初に実行：**
1. `process list` で実行中・完了したプロセスを確認
2. RUNNING_TASKS.md と照合
3. 完了したタスクがあれば：
   - Discord（#sns-投稿）に報告
   - RUNNING_TASKS.md を更新（「完了済み」に移動）
4. 食い違いがあれば修正

## 2. 自動バックアップ
ハートビート時にGitHubバックアップを実行してください：

```bash
/root/clawd/scripts/backup-with-retry.sh
```

## 3. ヘルスチェック
システムの安定性を確認します：

```bash
/root/clawd/scripts/health-check.sh
```

異常を検知した場合は、Discord（#sns-投稿）に報告してください。

## 4. 会話サマリー生成（1日1回）
前回から24時間以上経過している場合、今日の会話をサマリー化：

```bash
/root/clawd/scripts/daily-summary.sh
```

生成されたサマリーは `memory/YYYY-MM-DD.md` に保存されます。

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
