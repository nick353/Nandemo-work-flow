#!/bin/bash
# 浮世絵猫シリーズ転記スクリプト（VPS版）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_DIR="/root/clawd/cat_images"
LOG_FILE="$SCRIPT_DIR/transfer.log"

DOC_URL="https://docs.google.com/document/d/1j2lsvr1zJs9k9cCkLGeGF-soZZSGuY2p0tQ6wJp8S0s/edit?tab=t.0"
SHEET_URL="https://docs.google.com/spreadsheets/d/180Vjl8YwdM8tNy1suaYoq84FlbAdkc-uMvWh8aEc_3o/edit?gid=0#gid=0"

# ログ出力
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# エラーハンドリング
error_exit() {
    log "ERROR: $1"
    exit 1
}

log "=== 浮世絵猫シリーズ転記開始 ==="

# 画像保存ディレクトリ確認
mkdir -p "$IMAGE_DIR" || error_exit "画像ディレクトリ作成失敗"

# Clawdbotエージェントに処理を依頼
log "エージェントに処理を依頼..."

# メインセッションにメッセージを送信
clawdbot agent --message "$(cat <<'EOFMSG'
浮世絵猫シリーズの転記を実行してっぴ！

## 実行内容

### Step 1: スプレッドシート確認
- URL: https://docs.google.com/spreadsheets/d/180Vjl8YwdM8tNy1suaYoq84FlbAdkc-uMvWh8aEc_3o/edit?gid=0#gid=0
- browser toolで開く
- 現在登録されている画像数を確認
- D列（採用）の「○」をカウント
- 最終行番号を特定

### Step 2: Googleドキュメント確認
- URL: https://docs.google.com/document/d/1j2lsvr1zJs9k9cCkLGeGF-soZZSGuY2p0tQ6wJp8S0s/edit?tab=t.0
- browser toolで開く
- 全画像を検出
- 各画像の下のプロンプトテキストを取得
- スプレッドシートと照合して新規画像を特定

### Step 3: 新規画像処理（新規がある場合のみ）
各新規画像に対して：
1. 画像部分をスクリーンショット
   - 保存先: /root/clawd/cat_images/
   - ファイル名: ukiyoe_cat_YYYYMMDD_HHMMSS.png
2. プロンプトテキストを取得
3. プロンプトから日本語テーマを推測

### Step 4: スプレッドシートに追加
1. 次の空き行に移動
2. A列: 画像を挿入
3. B列: テーマ（日本語）
4. C列: プロンプト
5. D列: 「○」を選択

### Step 5: 未採用画像の削除
1. スプレッドシートでD列を確認
2. 「○」なし = 未採用
3. ドキュメントから該当画像とプロンプトを削除

### Step 6: 完了報告
- 追加した画像リスト
- 削除した画像リスト
- 採用状況サマリー

## テーマ推測ルール
| プロンプトキーワード | テーマ |
|-------------------|--------|
| cherry blossom, branch, loaf | 桜の枝の白猫 |
| snow, bamboo, black cat | 雪の竹林の黒猫 |
| calico, engawa, sun | 日向ぼっこの三毛猫 |
| white cat, cherry blossom | 桜の下の白猫 |
| open-air bath, Mount Fuji | 温泉の白猫 |
| roof, moon, night | 月夜の屋根猫 |
| bridge, autumn, maple | 紅葉橋の茶トラ |
| rain, shrine, hydrangea | 雨宿りの白猫 |

新規画像がない場合は「新規画像はありません」と報告して終了。

実行してっぴ！
EOFMSG
)" --thinking low

log "=== 転記処理完了 ==="
