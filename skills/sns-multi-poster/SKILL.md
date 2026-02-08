---
name: sns-multi-poster
description: Playwright MCPを使って5つのSNS（Instagram, Threads, Facebook, Pinterest, X）に画像を自動投稿。「SNS投稿」「マルチ投稿」でトリガー。
---

# SNS Multi Poster (Playwright MCP版)

## 概要

Playwright MCPを使用して、同一ブラウザセッション内でログイン状態を維持しながら、5つのSNSプラットフォームに画像とキャプションを投稿するスキル。

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
   例: /Users/username/Pictures/cat.jpg

2. **キャプション** (必須)
   例: ふぅ\n\n#猫のいる暮らし

3. **Pinterestボード名** (任意、デフォルト: Animal)
   例: Animal, イラスト, デザイン

4. **投稿先の選択** (任意、デフォルト: 全て)
   例: instagram,x,facebook
```

---

## Step 2: 投稿実行（Playwright MCP使用）

### 2-1. Instagram + Threads 投稿

```
1. browser_navigate → https://www.instagram.com/
2. 「新しい投稿」リンクをクリック (img[aria-label="新しい投稿"])
3. 「コンピューターから選択」ボタンをクリック
4. browser_file_upload → 画像ファイル
5. 「次へ」をクリック（2回: トリミング画面、フィルター画面）
6. キャプション入力欄にテキスト入力
7. 「シェア先」セクションでThreadsスイッチがオンか確認
8. 「シェア」をクリック
9. 「投稿をシェアしました」を確認
```

**重要なセレクタ:**
- 新規投稿: `link[aria-label="新しい投稿"]` または `img[aria-label="新しい投稿"]`
- ファイル選択: `button[name="コンピューターから選択"]`
- 次へ: `button[name="次へ"]`
- キャプション: `textbox[aria-label="キャプションを入力…"]`
- Threadsスイッチ: シェア先セクション内の `switch`
- シェア: `button[name="シェア"]`

### 2-2. X (Twitter) 投稿

```
1. browser_navigate → https://x.com/compose/post
2. テキストボックスにキャプション入力 (textbox[aria-label="Post text"])
3. browser_run_code でファイル入力を操作:
   const fileInput = await page.locator('input[type="file"][data-testid="fileInput"]').first();
   await fileInput.setInputFiles('画像パス');
4. Escキーでドロップダウンを閉じる
5. browser_evaluate でPostボタンをクリック:
   document.querySelector('button[data-testid="tweetButton"]').click()
```

**重要なセレクタ:**
- テキスト入力: `textbox[aria-label="Post text"]`
- ファイル入力: `input[type="file"][data-testid="fileInput"]`
- 投稿ボタン: `button[data-testid="tweetButton"]`

### 2-3. Facebook 投稿

```
1. browser_navigate → https://www.facebook.com/
2. 「What's on your mind」ボタンをクリック
3. テキストボックスにキャプション入力
4. 「Photo/video」ボタンをクリック
5. browser_file_upload → 画像ファイル
6. 「Next」をクリック
7. 「Post」をクリック
8. WhatsAppダイアログが出たら「Not now」をクリック
```

**重要なセレクタ:**
- 投稿作成: `button[aria-label="What's on your mind"]`
- テキスト入力: `textbox` (ダイアログ内)
- 写真追加: `button[name="Photo/video"]`
- 次へ: `button[name="Next"]`
- 投稿: `button[name="Post"]`

### 2-4. Pinterest 投稿

```
1. browser_navigate → https://jp.pinterest.com/pin-creation-tool/
2. 「ファイルのアップロード」ボタンをクリック
3. browser_file_upload → 画像ファイル
4. タイトル入力 (textbox[aria-label="タイトル"])
5. 説明文エディタをクリックしてキャプション入力
6. ボード選択ドロップダウンをクリック
7. ボード名（例: Animal）を選択
8. 「公開する」をクリック
```

**重要なセレクタ:**
- ファイルアップロード: `button[name="ファイルのアップロード"]`
- タイトル: `textbox[aria-label="タイトル"]`
- 説明文: `button[name="テキストエディタ"]`
- ボード選択: `button[aria-label*="ボードを選択"]`
- 公開: `button[name="公開する"]`

---

## 実行例

### 入力

```
画像: /Users/nichikatanaka/Pictures/ukiyoe-cat.jpg
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

Playwright MCPは独立したブラウザセッションを使用するため、**最初の実行時に各SNSへのログインが必要**です。

ログイン手順:
1. スキル実行開始
2. ブラウザが開く
3. 各SNSに順番にアクセス
4. ログインが必要な場合は手動でログイン
5. 同一セッション内でログイン状態が維持される

### セッション維持のコツ

- 1回のスキル実行中は同じブラウザセッションを使用
- セッションが切れた場合は再ログインが必要
- 長時間放置するとセッションタイムアウトの可能性あり

### エラー対処

| エラー | 対処法 |
|--------|--------|
| ログイン画面が表示される | 手動でログインしてから再実行 |
| 要素が見つからない | ページ読み込み待機 (`browser_wait_for`) |
| クリックできない | `browser_evaluate` でJSから直接クリック |
| ファイルアップロード失敗 | `browser_run_code` でlocatorを使用 |

---

## 実際の動作コード（Claude Code用）

このスキルが呼び出されたら、以下のフローで実行：

### Instagram + Threads

```javascript
// 1. Instagramにアクセス
await mcp__playwright__browser_navigate({ url: "https://www.instagram.com/" });

// 2. 新規投稿ボタンをクリック
await mcp__playwright__browser_click({ ref: "[新しい投稿のref]", element: "新しい投稿ボタン" });

// 3. ファイル選択
await mcp__playwright__browser_click({ ref: "[コンピューターから選択のref]", element: "ファイル選択ボタン" });
await mcp__playwright__browser_file_upload({ paths: ["画像パス"] });

// 4. 次へ（2回）
await mcp__playwright__browser_click({ ref: "[次へのref]", element: "次へボタン" });
await mcp__playwright__browser_click({ ref: "[次へのref]", element: "次へボタン" });

// 5. キャプション入力
await mcp__playwright__browser_type({ ref: "[キャプション入力のref]", text: "キャプション", element: "キャプション入力欄" });

// 6. シェア
await mcp__playwright__browser_click({ ref: "[シェアのref]", element: "シェアボタン" });
```

### X (Twitter)

```javascript
// 1. 投稿画面にアクセス
await mcp__playwright__browser_navigate({ url: "https://x.com/compose/post" });

// 2. テキスト入力
await mcp__playwright__browser_type({ ref: "[Post textのref]", text: "キャプション", element: "投稿テキスト" });

// 3. 画像アップロード（run_code使用）
await mcp__playwright__browser_run_code({
  code: `async (page) => {
    const fileInput = await page.locator('input[type="file"][data-testid="fileInput"]').first();
    await fileInput.setInputFiles('画像パス');
    return 'uploaded';
  }`
});

// 4. 投稿
await mcp__playwright__browser_press_key({ key: "Escape" });
await mcp__playwright__browser_evaluate({
  function: "() => { document.querySelector('button[data-testid=\"tweetButton\"]').click(); }"
});
```

### Facebook

```javascript
// 1. Facebookにアクセス
await mcp__playwright__browser_navigate({ url: "https://www.facebook.com/" });

// 2. 投稿作成
await mcp__playwright__browser_click({ ref: "[What's on your mindのref]", element: "投稿作成ボタン" });

// 3. テキスト入力
await mcp__playwright__browser_type({ ref: "[textboxのref]", text: "キャプション", element: "テキスト入力欄" });

// 4. 写真追加
await mcp__playwright__browser_click({ ref: "[Photo/videoのref]", element: "写真追加ボタン" });
await mcp__playwright__browser_file_upload({ paths: ["画像パス"] });

// 5. 投稿
await mcp__playwright__browser_click({ ref: "[Nextのref]", element: "Nextボタン" });
await mcp__playwright__browser_click({ ref: "[Postのref]", element: "Postボタン" });
```

### Pinterest

```javascript
// 1. ピン作成ツールにアクセス
await mcp__playwright__browser_navigate({ url: "https://jp.pinterest.com/pin-creation-tool/" });

// 2. ファイルアップロード
await mcp__playwright__browser_click({ ref: "[ファイルのアップロードのref]", element: "アップロードボタン" });
await mcp__playwright__browser_file_upload({ paths: ["画像パス"] });

// 3. タイトル入力
await mcp__playwright__browser_type({ ref: "[タイトルのref]", text: "タイトル", element: "タイトル入力欄" });

// 4. 説明文入力
await mcp__playwright__browser_click({ ref: "[テキストエディタのref]", element: "説明文エディタ" });
await mcp__playwright__browser_run_code({
  code: `async (page) => { await page.keyboard.type('キャプション'); }`
});

// 5. ボード選択
await mcp__playwright__browser_click({ ref: "[ボード選択のref]", element: "ボードドロップダウン" });
await mcp__playwright__browser_click({ ref: "[ボード名のref]", element: "ボード名" });

// 6. 公開
await mcp__playwright__browser_click({ ref: "[公開するのref]", element: "公開ボタン" });
```

---

## 更新履歴

- 2026-02-01: Playwright MCP版に全面改訂。実際の動作確認済みのフローを反映。
