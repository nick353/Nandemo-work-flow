---
name: sns-multi-poster
description: 5つのSNS（Instagram, Threads, Facebook, Pinterest, X）に画像を自動投稿。「SNS投稿」「マルチ投稿」でトリガー。
---

# SNS Multi Poster (Clawdbot標準版)

## 概要

Clawdbot標準browserツールを使用して、5つのSNSプラットフォームに画像とキャプションを自動投稿するスキル。

**対応プラットフォーム:**
- Instagram（+ Threads同時投稿）
- Facebook
- Pinterest
- X (Twitter)

**重要:** ThreadsはInstagram投稿時の「シェア先」スイッチをオンにすることで同時投稿される。

---

## トリガーワード

- `SNS投稿`
- `マルチ投稿`
- `5つのSNSに投稿`
- `/sns-multi-poster`

---

## 起動時の動作

### Step 1: ヒアリング

```
🚀 SNS Multi Poster

投稿に必要な情報を教えてください：

1. **投稿する画像のパス** (必須)
   例: /root/Pictures/cat.jpg

2. **キャプション** (必須)
   例: ふぅ\n\n#猫のいる暮らし

3. **Pinterestボード名** (任意、デフォルト: Animal)
   例: Animal, イラスト, デザイン

4. **投稿先の選択** (任意、デフォルト: 全て)
   例: instagram,x,facebook
```

---

## Step 2: 投稿実行（Clawdbot browserツール使用）

### 2-1. Instagram + Threads 投稿

```javascript
// 1. Instagramにアクセス
await browser({ action: "navigate", targetUrl: "https://www.instagram.com/" });

// 2. ページ読み込み待機
await browser({ action: "snapshot", refs: "aria" });

// 3. 新規投稿ボタンをクリック
// snapshot結果から「新しい投稿」リンクのrefを取得してクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<新しい投稿のref>" 
  } 
});

// 4. ファイルアップロード準備
await browser({ 
  action: "upload", 
  paths: ["<画像パス>"] 
});

// 5. 「コンピューターから選択」をクリック（ファイル選択ダイアログが開く）
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<コンピューターから選択のref>" 
  } 
});

// 6. 「次へ」を2回クリック（トリミング → フィルター）
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<次へのref>" 
  } 
});

await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<次へのref>" 
  } 
});

// 7. キャプション入力
await browser({ 
  action: "act", 
  request: { 
    kind: "type", 
    ref: "<キャプション入力欄のref>",
    text: "<キャプション>" 
  } 
});

// 8. Threadsスイッチ確認（ONになっているか）
// スイッチがOFFならクリックしてONにする

// 9. 「シェア」をクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<シェアボタンのref>" 
  } 
});

// 10. 完了確認（「投稿をシェアしました」が表示されるまで待機）
```

**重要なセレクタ（snapshot時に探す要素）:**
- 新規投稿: `link` role, name="新しい投稿"
- ファイル選択: `button` role, name="コンピューターから選択"
- 次へ: `button` role, name="次へ"
- キャプション: `textbox` role, name="キャプションを入力…"
- Threadsスイッチ: `switch` role
- シェア: `button` role, name="シェア"

---

### 2-2. X (Twitter) 投稿

```javascript
// 1. 投稿画面にアクセス
await browser({ action: "navigate", targetUrl: "https://x.com/compose/post" });

// 2. snapshot取得
await browser({ action: "snapshot", refs: "aria" });

// 3. テキスト入力
await browser({ 
  action: "act", 
  request: { 
    kind: "type", 
    ref: "<Post textのref>",
    text: "<キャプション>" 
  } 
});

// 4. 画像アップロード（file inputに直接セット）
// file input要素のrefを取得してupload
await browser({ 
  action: "upload", 
  paths: ["<画像パス>"],
  inputRef: "<file inputのref>"
});

// 5. Postボタンをクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<Postボタンのref>" 
  } 
});
```

**重要なセレクタ:**
- テキスト入力: `textbox` role, name="Post text"
- ファイル入力: `input[type="file"][data-testid="fileInput"]`
- 投稿ボタン: `button` role, data-testid="tweetButton"

---

### 2-3. Facebook 投稿

```javascript
// 1. Facebookにアクセス
await browser({ action: "navigate", targetUrl: "https://www.facebook.com/" });

// 2. snapshot
await browser({ action: "snapshot", refs: "aria" });

// 3. 投稿作成ボタンをクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<What's on your mindのref>" 
  } 
});

// 4. テキスト入力
await browser({ 
  action: "act", 
  request: { 
    kind: "type", 
    ref: "<textboxのref>",
    text: "<キャプション>" 
  } 
});

// 5. 写真追加ボタンをクリック
await browser({ 
  action: "upload", 
  paths: ["<画像パス>"] 
});

await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<Photo/videoのref>" 
  } 
});

// 6. 「Next」をクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<Nextのref>" 
  } 
});

// 7. 「Post」をクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<Postのref>" 
  } 
});

// 8. WhatsAppダイアログが出たら「Not now」をクリック
// （snapshot で確認してから実行）
```

**重要なセレクタ:**
- 投稿作成: `button` role, name="What's on your mind"
- テキスト入力: `textbox` role
- 写真追加: `button` role, name="Photo/video"
- 次へ: `button` role, name="Next"
- 投稿: `button` role, name="Post"

---

### 2-4. Pinterest 投稿

```javascript
// 1. ピン作成ツールにアクセス
await browser({ action: "navigate", targetUrl: "https://jp.pinterest.com/pin-creation-tool/" });

// 2. snapshot
await browser({ action: "snapshot", refs: "aria" });

// 3. ファイルアップロード準備
await browser({ 
  action: "upload", 
  paths: ["<画像パス>"] 
});

// 4. 「ファイルのアップロード」をクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<ファイルのアップロードのref>" 
  } 
});

// 5. タイトル入力
await browser({ 
  action: "act", 
  request: { 
    kind: "type", 
    ref: "<タイトルのref>",
    text: "<タイトル>" 
  } 
});

// 6. 説明文入力
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<テキストエディタのref>" 
  } 
});

await browser({ 
  action: "act", 
  request: { 
    kind: "type", 
    ref: "<説明文入力欄のref>",
    text: "<キャプション>" 
  } 
});

// 7. ボード選択
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<ボード選択のref>" 
  } 
});

await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<ボード名のref>" 
  } 
});

// 8. 「公開する」をクリック
await browser({ 
  action: "act", 
  request: { 
    kind: "click", 
    ref: "<公開するのref>" 
  } 
});
```

**重要なセレクタ:**
- ファイルアップロード: `button` role, name="ファイルのアップロード"
- タイトル: `textbox` role, name="タイトル"
- 説明文: `button` role, name="テキストエディタ"
- ボード選択: `button` role, name contains "ボードを選択"
- 公開: `button` role, name="公開する"

---

## 実行例

### 入力

```
画像: /root/Pictures/ukiyoe-cat.jpg
キャプション: ふぅ

#猫のいる暮らし
Pinterestボード: Animal
投稿先: 全て
```

### 出力

```
📸 Instagram + Threads: ✅ 成功
🐦 X (Twitter): ✅ 成功
📘 Facebook: ✅ 成功
📌 Pinterest: ✅ 成功

投稿完了！
```

---

## 注意事項

### ログイン状態について

Clawdbot browserツールは独立したブラウザプロファイルを使用するため、**最初の実行時に各SNSへのログインが必要**です。

ログイン手順:
1. スキル実行開始
2. ブラウザが開く
3. 各SNSに順番にアクセス
4. ログインが必要な場合は手動でログイン
5. 同一プロファイル内でログイン状態が維持される

### セッション維持のコツ

- 同じbrowserプロファイル（デフォルト: "clawd"）を使用
- セッションが切れた場合は再ログインが必要
- 長時間放置するとセッションタイムアウトの可能性あり

### エラー対処

| エラー | 対処法 |
|--------|--------|
| ログイン画面が表示される | 手動でログインしてから再実行 |
| 要素が見つからない | snapshot再取得 → refを更新 |
| クリックできない | screenshot で確認 → セレクタ調整 |
| ファイルアップロード失敗 | upload action を再実行 |

---

## 自動修正ポイント（VPSテスト時）

VPSでテスト実行時に自動修正する項目：

1. **セレクタ調整**
   - snapshot結果からref取得
   - 要素が見つからない場合は類似要素を探す

2. **タイミング調整**
   - ページ読み込み待機
   - 要素表示待機

3. **スクリーンショット取得**
   - エラー時に自動でscreenshot取得
   - Discord (#sns-投稿) に送信

4. **リトライ処理**
   - 失敗時は3回まで自動リトライ
   - セレクタを調整してから再実行

---

## 更新履歴

- 2026-02-08: Clawdbot標準browserツール版に変換（VPS対応）
- 2026-02-01: Playwright MCP版作成（ローカル開発用）
