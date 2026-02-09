# HEARTBEAT.md - 自動タスク

## 1. 実行中タスクのチェック（最優先）
**必ず最初に実行：**
1. `process list` で実行中・完了したプロセスを確認
2. RUNNING_TASKS.md と照合
3. 完了したタスクがあれば：
   - **即座に** 元のチャンネル（約束した場所）に報告
   - RUNNING_TASKS.md を更新（「完了済み」に移動）
4. 食い違いがあれば修正

**⚠️ 絶対守るルール：**
- 「完了したら報告する」と言ったら **必ず** 報告する
- andoさんから聞かれる前に **自分から** 報告する
- 約束を守らない = 信頼を失う
- **「確認する」と言ったら、確認結果を必ず報告する**
- **エラーや予期しない結果を見つけたら、黙って調査せず即報告**

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

## 5. Clawdbot自動リサーチ（毎朝）
最新のSkills・MCP・Tips・事例を自動収集：

```bash
/root/clawd/scripts/daily-research.sh
```

レポートは `research/YYYY-MM-DD.md` に保存され、Discord（#自己強化の間）に自動投稿されます。

**リサーチ範囲:**
- ClawdHub: 新しいSkills
- GitHub: MCPサーバー・Clawdbot関連リポジトリ
- X（Twitter）: コミュニティTips・事例（認証設定後）

**重要度分類:**
- 🔴 高優先度: 即導入推奨
- 🟡 中優先度: 検討推奨
- 🟢 低優先度: 参考情報

**担当:** リッキー 🐥

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
