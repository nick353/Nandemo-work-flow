# Zeabur 安定稼働設定ガイド

このガイドは、ClawdbotをZeabur上で「止まらないように」設定する方法をまとめたものです。

## 1. ヘルスチェック設定（Zeaburダッシュボード）

Zeaburのサービス設定でヘルスチェックを有効化してください：

```yaml
health_check:
  path: /health
  port: 8080
  interval: 30s
  timeout: 10s
  retries: 3
```

### 設定方法
1. Zeaburダッシュボードを開く
2. Clawdbotサービスを選択
3. "Health Check" タブを開く
4. 以下を設定：
   - **Path**: `/health` または `/`
   - **Port**: `8080`
   - **Interval**: `30` (秒)
   - **Timeout**: `10` (秒)
   - **Retries**: `3`

## 2. 自動再起動設定

Zeaburは以下の場合に自動的にコンテナを再起動します：
- ✅ ヘルスチェックが連続で失敗した場合
- ✅ プロセスがクラッシュした場合（PID 1が停止）
- ✅ OOMキラー（メモリ不足）で停止した場合

### 再起動ポリシー
デフォルトで `always` ポリシーが適用されています（変更不要）

## 3. Discord通知設定（オプション）

異常時にDiscordへ通知を送る場合、環境変数を追加：

```
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN
```

### Webhook URLの取得方法
1. Discord サーバー設定 → 連携サービス → ウェブフック
2. "新しいウェブフック" をクリック
3. 名前を設定（例: Clawdbot Alerts）
4. チャンネルを選択
5. "ウェブフックURLをコピー" をクリック
6. Zeaburの環境変数に `DISCORD_WEBHOOK_URL` として追加

## 4. リソース設定

メモリ不足による停止を防ぐため、適切なリソースを割り当てる：

```
Memory: 512MB 以上推奨（1GB が理想）
CPU: 0.5 コア以上
```

### Zeaburでのリソース確認
1. サービス選択 → "Resources" タブ
2. メモリ使用率を確認
3. 80%を超える場合はプラン変更を検討

## 5. ログ監視

Zeaburの "Logs" タブで以下を確認：
- `✅ Health check passed` - 正常動作
- `❌ ERROR` - エラー発生
- `🔄 Watchdog Alert` - 監視アラート

### ログファイルの場所
- `/root/clawd/.clawdbot-backup/logs/health-check.log`
- `/root/clawd/.clawdbot-backup/logs/watchdog.log`

## 6. バックアップ

自動バックアップが毎日実行されます：
- **スクリプト**: `/root/clawd/scripts/backup-with-retry.sh`
- **実行タイミング**: ハートビート時（定期的）
- **バックアップ先**: GitHub リポジトリ

## 7. 復元手順（VPS再起動後）

Zeaburボリュームマウントにより、自動的に以下が復元されます：
- ✅ `/root/clawd` - 全ワークスペースファイル
- ✅ `.clawdbot-backup` - バックアップデータ

設定ファイルが消えた場合は自動復元スクリプトが実行されます。

## 8. トラブルシューティング

### プロセスが頻繁に再起動する場合
1. ログを確認: `cat /root/clawd/.clawdbot-backup/logs/health-check.log`
2. メモリ使用率を確認: Zeabur "Resources" タブ
3. APIキーの有効性を確認: Anthropic Console

### ヘルスチェックが失敗する場合
```bash
# 手動でヘルスチェック実行
bash /root/clawd/scripts/health-check.sh
```

### プロセス状態を確認
```bash
ps aux | grep clawdbot-gateway
netstat -tuln | grep 8080
```

## 9. 監視スクリプト

以下のスクリプトが用意されています：
- `health-check.sh` - ヘルスチェック（手動実行可）
- `watchdog.sh` - プロセス監視（バックグラウンド実行）

### Watchdog起動（オプション）
```bash
nohup bash /root/clawd/scripts/watchdog.sh > /dev/null 2>&1 &
```

※ 通常はZeaburのヘルスチェック機能で十分です

## まとめ

✅ **必須設定**:
- Zeaburヘルスチェック有効化
- リソース確認（メモリ512MB以上）

✅ **推奨設定**:
- Discord Webhook通知
- ログ定期確認

✅ **自動化済み**:
- プロセス再起動（Zeabur）
- 設定自動復元（startup.sh）
- バックアップ（HEARTBEAT.md）

---

**これで Clawdbot は「止まらない」設定が完了です！** 🎉
