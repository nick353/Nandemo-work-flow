# HEARTBEAT.md - 自動タスク

## 0. Discord投稿待ちチェック（最優先）
**リサーチ完了後の自動投稿:**
```bash
if [ -f /root/clawd/.discord_post_pending ]; then
    echo "🔔 Discord投稿待ちを検知"
    # フラグファイルから情報読み取り
    DATE=$(head -1 /root/clawd/.discord_post_pending)
    REPORT_FILE=$(sed -n '2p' /root/clawd/.discord_post_pending)
    
    # レポートファイルが存在すればDiscord投稿
    if [ -f "$REPORT_FILE" ]; then
        echo "📤 $DATE のレポートをDiscord投稿します"
        # ここでリッキーが自動投稿する
        # （レポート内容を読み込んでmessage toolで投稿）
    fi
    
    # フラグファイル削除
    rm -f /root/clawd/.discord_post_pending
fi
```

## 1. 毎朝リサーチの自動実行チェック
**日本時間9:00（UTC 0:00）に自動実行：**
```bash
TODAY=$(date +%Y-%m-%d)
LAST_RUN=$(cat /root/clawd/.last_research_date 2>/dev/null || echo "1970-01-01")

if [ "$TODAY" != "$LAST_RUN" ]; then
    CURRENT_HOUR=$(date +%H)
    # UTC 0時台（日本時間9時台）にチェック
    if [ "$CURRENT_HOUR" = "00" ] || [ "$CURRENT_HOUR" = "01" ]; then
        echo "🔍 毎朝リサーチを開始します..."
        . ~/.profile && /root/clawd/scripts/daily-research.sh
        echo "$TODAY" > /root/clawd/.last_research_date
        echo "✅ リサーチ完了"
    fi
fi
```

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

### ⏰ スケジュール
- 毎朝自動実行（cronジョブ）
- レポート生成 → Discord投稿

### 📋 実行内容
1. **GitHub検索**（⭐500以上、最新順）
2. **X言及数カウント**（各ツール名で検索）
3. **話題度スコア計算**（GitHub⭐ + X言及×100）
4. **厳選3件**をピックアップ
5. Discord投稿（#自己強化の間）

### 📤 投稿フォーマット
```
# 🔥 今日の話題（前日の注目ツール）

## 1. **ツール名** by 作者

**⭐ スター数** | 🔥 話題度: 高（X言及 N件） | スコア: XXXX

**何ができる:**  
説明文

**Xでの反応:**
- @user: "実際の感想..."

**💬 やってみますか？**
```

### 🔄 運用フロー
1. ハートビート時：日付チェック → 新しい日なら自動実行
2. レポート生成 → Discord投稿
3. andoさんが「やってみる」と言ったら → インストール実行
4. 完了報告

### 🎯 話題性判定基準
- **⭐ GitHub:** 500以上が対象
- **🔥 X言及:** 3件以上で「話題度: 高」
- **📊 スコア:** GitHub⭐ + (X言及数 × 100)
- **📋 表示:** トップ3のみ（厳選）

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
