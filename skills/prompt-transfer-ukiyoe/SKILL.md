# prompt-transfer-ukiyoe

浮世絵猫シリーズ専用の画像・プロンプト転記スキル（VPS版）

---

## 概要

Googleドキュメントから新規画像を検出し、スプレッドシートに自動転記。未採用画像は自動削除。

---

## 固定設定

| 項目 | 値 |
|------|-----|
| ドキュメントURL | https://docs.google.com/document/d/1j2lsvr1zJs9k9cCkLGeGF-soZZSGuY2p0tQ6wJp8S0s/edit?tab=t.0 |
| スプレッドシートURL | https://docs.google.com/spreadsheets/d/180Vjl8YwdM8tNy1suaYoq84FlbAdkc-uMvWh8aEc_3o/edit?gid=0#gid=0 |
| シリーズ | 浮世絵 猫シリーズ |
| 画像保存先 | `/root/clawd/cat_images/` |

---

## 実行フロー

### Step 1: スプレッドシート確認
1. スプレッドシートを開く
2. 登録済み画像とプロンプトを確認
3. D列（採用）の「○」をリスト化
4. 最終行番号を特定

### Step 2: ドキュメント確認
1. Googleドキュメントを開く
2. 全画像とプロンプトを取得
3. スプレッドシートと照合して新規画像を検出
4. 新規がなければ終了

### Step 3: 新規画像処理
各新規画像に対して：
1. 画像部分をスクリーンショット保存
2. プロンプトテキストを取得
3. プロンプトから日本語テーマを推測

### Step 4: スプレッドシートに追加
1. 次の空き行に移動
2. A列: 画像を挿入
3. B列: テーマ（日本語）
4. C列: プロンプト
5. D列: 「○」（採用）

### Step 5: 未採用画像の削除
1. スプレッドシートD列を確認
2. 「○」なし = 未採用
3. ドキュメントから該当画像とプロンプトを削除

### Step 6: 完了報告
```
✅ 転記完了

【追加】
- 行XX: [テーマ] - [プロンプト冒頭]

【削除】
- [テーマ] - 未採用のため削除

【採用状況】
- 採用済み（○）: XX件
- 削除済み: XX件
```

---

## 実装

### browser tool使用パターン

```javascript
// Step 1: スプレッドシート確認
await browser.open({
  profile: "clawd",
  targetUrl: "https://docs.google.com/spreadsheets/d/180Vjl8YwdM8tNy1suaYoq84FlbAdkc-uMvWh8aEc_3o/edit?gid=0#gid=0"
});

let snapshot = await browser.snapshot({ targetId });

// D列の「○」をカウント
// 最終行番号を特定

// Step 2: ドキュメント確認
await browser.open({
  targetUrl: "https://docs.google.com/document/d/1j2lsvr1zJs9k9cCkLGeGF-soZZSGuY2p0tQ6wJp8S0s/edit?tab=t.0"
});

snapshot = await browser.snapshot({ targetId });

// 画像要素を検出
// 各画像の下のプロンプトテキストを取得

// Step 3: 新規画像処理
for (const newImage of newImages) {
  // スクリーンショット保存
  await browser.screenshot({
    targetId,
    element: imageSelector,
    fullPage: false
  });
  
  // ファイル名: cat_ukiyoe_YYYYMMDD_HHMMSS.png
  // 保存先: /root/clawd/cat_images/
  
  // プロンプトからテーマ推測
  const theme = inferTheme(prompt);
}

// Step 4: スプレッドシート追加
await browser.navigate({ targetId, targetUrl: sheetUrl });

// 次の空き行に移動
await browser.act({
  request: { kind: "click", ref: "A{nextRow}" }
});

// 画像挿入（Insert > Image > Upload）
// B列: テーマ入力
// C列: プロンプト入力
// D列: 「○」選択

// Step 5: 未採用削除
// ドキュメントに戻る
// D列空白の画像を削除
```

---

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

---

## 注意事項

1. **Googleアカウント認証**
   - browser profile "clawd" でログイン済みが前提
   - 初回実行時にログインが必要な場合あり

2. **画像座標**
   - Googleドキュメントの画像は中央配置
   - element selectorで特定してスクリーンショット

3. **エラーハンドリング**
   - 新規画像なし → 正常終了
   - 認証エラー → 再ログイン促す
   - ネットワークエラー → リトライ

---

## 定期実行

**cron設定:**
```
毎日12:00 JST（03:00 UTC）
```

**実行コマンド:**
```bash
clawdbot agent --message "浮世絵猫の転記を実行してっぴ" --channel discord --target sns-投稿
```
