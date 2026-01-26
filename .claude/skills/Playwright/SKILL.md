---
name: playwright-actions
description: |
  Playwright MCPでブラウザ操作を行うスキル。
  人間がブラウザで調べ物をするのと同じように、検索・閲覧・リンク辿り・複数ソース比較・情報整理を自律的に行う。

  **このスキルは以下の場合に自動的に使用されます：**
  - URLが含まれるリクエスト（https://、http://）
  - Webページの閲覧・確認が必要なリクエスト
  - X/Twitter、SPAなどJavaScriptが必要なサイトへのアクセス
  - 「調べて」「検索して」「リサーチして」などの調査リクエスト

  WebFetchやWebSearchではなく、必ずPlaywright MCPを使用すること。

triggers:
  # URL patterns
  - https://
  - http://
  - x.com
  - twitter.com
  - github.com
  - "*.com"
  - "*.io"
  - "*.dev"
  - "*.app"

  # Actions
  - /open
  - /scroll
  - /setup
  - /init
  - /install
  - /get-text
  - /get-url
  - /get-page-info
  - /is-visible
  - /focus
  - /clear
  - /screenshot
  - /snapshot
  - /search
  - /back
  - /forward
  - /tabs
  - /research

  # Natural language - Japanese
  - このURLを
  - このページを
  - このサイトを
  - 開いて
  - 見て
  - 確認して
  - アクセスして
  - 調べて
  - リサーチして
  - 検索して
  - 探して
  - 比較して
  - まとめて
  - スクロールして
  - スクショ
  - スクリーンショット
  - ググって
  - ネットで

  # Natural language - English
  - open this
  - check this
  - visit
  - browse
  - look at
  - research
  - scroll
  - screenshot
  - search for
  - google
  - find out
  - look up
  - compare
---

# Playwright Browser スキル

**人間がブラウザで調べ物をするのと同じように、自律的にWebを操作する。**

---

## 基本方針

このスキルが読み込まれたら、**人間がブラウザを使うときと同じ行動**をとること。

人間は：
1. 知りたいことがあれば **検索エンジンで検索** する
2. 検索結果を **読んで判断** し、良さそうなリンクを **クリック** する
3. ページを **スクロールして読む** 、必要な情報を探す
4. 足りなければ **戻って別のリンク** を試す、または **検索ワードを変えて再検索** する
5. 複数のページを見て **情報を比較・整理** する
6. ポップアップやCookie同意が出たら **閉じる**
7. 最終的に **見つけた情報をまとめて** 伝える

Claudeもこれと全く同じことをPlaywright MCPで行うこと。

---

## 絶対ルール

1. **Webアクセスは全てPlaywright MCPで行う** — WebFetch/WebSearch/curl/wget は使わない
2. **URLが渡されたら開く、質問が渡されたら検索から始める**
3. **ページを開いたら必ず内容を読む** — スクショだけ撮って終わりにしない
4. **情報が足りなければ自分で追加調査する** — 1ページで諦めない
5. **最終的にユーザーの質問に答える** — ブラウザ操作の報告ではなく、調べた結果を伝える

---

## ツール一覧

### ページ操作

| 操作 | ツール |
|------|--------|
| URLを開く | `mcp__playwright__browser_navigate({ url: "..." })` |
| ページ内容を読む | `mcp__playwright__browser_snapshot({})` |
| スクリーンショット | `mcp__playwright__browser_take_screenshot({ filename: "...", type: "png" })` |
| 読み込み待機 | `mcp__playwright__browser_wait_for({ time: 3 })` |
| 戻る | `mcp__playwright__browser_navigate({ url: "javascript:history.back()" })` または `mcp__playwright__browser_press_key({ key: "Alt+ArrowLeft" })` |
| 進む | `mcp__playwright__browser_press_key({ key: "Alt+ArrowRight" })` |
| リロード | `mcp__playwright__browser_press_key({ key: "F5" })` |

### 要素操作

| 操作 | ツール |
|------|--------|
| クリック | `mcp__playwright__browser_click({ element: "説明", ref: "<ref>" })` |
| テキスト入力 | `mcp__playwright__browser_type({ element: "説明", ref: "<ref>", text: "テキスト" })` |
| キー入力 | `mcp__playwright__browser_press_key({ key: "Enter" })` |
| ホバー | `mcp__playwright__browser_hover({ element: "説明", ref: "<ref>" })` |

### スクロール

| 操作 | ツール |
|------|--------|
| ページダウン | `mcp__playwright__browser_press_key({ key: "PageDown" })` |
| ページアップ | `mcp__playwright__browser_press_key({ key: "PageUp" })` |
| 先頭へ | `mcp__playwright__browser_press_key({ key: "Home" })` |
| 末尾へ | `mcp__playwright__browser_press_key({ key: "End" })` |
| 指定要素へ | `mcp__playwright__browser_evaluate({ function: "(el) => el.scrollIntoView({ behavior: 'smooth' })", ref: "<ref>", element: "説明" })` |

### 情報取得

| 操作 | ツール |
|------|--------|
| テキスト取得 | `mcp__playwright__browser_evaluate({ function: "(el) => el.textContent", ref: "<ref>", element: "説明" })` |
| 属性取得 | `mcp__playwright__browser_evaluate({ function: "(el) => el.getAttribute('href')", ref: "<ref>", element: "説明" })` |
| 現在のURL | `mcp__playwright__browser_evaluate({ function: "() => location.href" })` |
| ページタイトル | `mcp__playwright__browser_evaluate({ function: "() => document.title" })` |
| 表示状態 | `mcp__playwright__browser_evaluate({ function: "(el) => el.offsetParent !== null", ref: "<ref>", element: "説明" })` |
| input値 | `mcp__playwright__browser_evaluate({ function: "(el) => el.value", ref: "<ref>", element: "説明" })` |
| 要素数 | `mcp__playwright__browser_evaluate({ function: "() => document.querySelectorAll('selector').length" })` |
| Cookie | `mcp__playwright__browser_evaluate({ function: "() => document.cookie" })` |
| LocalStorage | `mcp__playwright__browser_evaluate({ function: "() => JSON.stringify(localStorage)" })` |

### タブ操作

| 操作 | ツール |
|------|--------|
| 新しいタブ | `mcp__playwright__browser_tab_new({ url: "..." })` |
| タブ一覧 | `mcp__playwright__browser_tab_list({})` |
| タブ切替 | `mcp__playwright__browser_tab_select({ index: 0 })` |
| タブを閉じる | `mcp__playwright__browser_tab_close({})` |

### その他

| 操作 | ツール |
|------|--------|
| フォーカス | `mcp__playwright__browser_evaluate({ function: "(el) => el.focus()", ref: "<ref>", element: "説明" })` |
| クリア | `mcp__playwright__browser_evaluate({ function: "(el) => { el.value = ''; el.dispatchEvent(new Event('input', { bubbles: true })); }", ref: "<ref>", element: "説明" })` |
| JS実行 | `mcp__playwright__browser_evaluate({ function: "() => { ... }" })` |

---

## 行動パターン

### パターン1: URLが渡された場合

ユーザーがURLを指定 → そのページを開いて内容を読み、情報を伝える。

```
1. browser_navigate({ url: "指定URL" })
2. browser_wait_for({ time: 3 })
3. browser_snapshot({})              ← ページ内容を読む
4. 必要ならスクロールして続きを読む
5. 必要ならスクリーンショットを撮る
6. 内容をユーザーに伝える
```

### パターン2: 調べ物を頼まれた場合（URLなし）

ユーザーが「〜について調べて」→ Google検索から始める。

```
1. browser_navigate({ url: "https://www.google.com" })
2. browser_snapshot({})              ← 検索ボックスのrefを取得
3. browser_click({ element: "検索ボックス", ref: "<ref>" })
4. browser_type({ element: "検索ボックス", ref: "<ref>", text: "検索ワード" })
5. browser_press_key({ key: "Enter" })
6. browser_wait_for({ time: 3 })
7. browser_snapshot({})              ← 検索結果を読む
8. 良さそうなリンクをクリック
9. ページ内容を読む
10. 足りなければ戻って別のリンク、または検索ワードを変えて再検索
11. 十分な情報が集まったらユーザーに報告
```

### パターン3: 複数ソースの比較

```
1. まずソースAを開いて読む
2. 重要な情報を記憶（内部的にメモ）
3. ソースBを開いて読む
4. 両方の情報を比較・整理
5. ユーザーに結果を報告
```

### パターン4: SNS投稿の確認（X/Twitter等）

```
1. browser_navigate({ url: "https://x.com/..." })
2. browser_wait_for({ time: 5 })    ← SPAは読み込みに時間がかかる
3. browser_snapshot({})
4. 投稿テキスト、画像、エンゲージメント等を読み取る
5. リプライやスレッドがあればスクロールして読む
6. 内容をユーザーに伝える
```

### パターン5: ページ内の特定情報を探す

```
1. ページを開く
2. snapshot で全体を確認
3. 見つからなければ PageDown でスクロール → 再度 snapshot
4. それでも見つからなければ Ctrl+F 的にページ内検索:
   browser_evaluate({ function: "() => document.body.innerText.includes('検索ワード')" })
5. 見つかった位置にスクロール
```

---

## 障害への対応

### ポップアップ・Cookie同意バナー

snapshotで「Accept」「同意」「閉じる」等のボタンが見えたら、クリックして閉じる。

```
browser_snapshot({})  ← バナーのrefを確認
browser_click({ element: "Cookieバナーの同意ボタン", ref: "<ref>" })
```

### ログイン壁

ページ内容がログインフォームしか表示しない場合：
1. ユーザーに「ログインが必要です。認証情報はありますか？」と確認
2. 認証情報があれば入力してログイン
3. なければ代替手段を提案（キャッシュ版、別ソース等）

### ページが読み込めない

1. 3秒待機 → 再度snapshot
2. それでもダメなら5秒待機 → リロード
3. それでもダメならユーザーに報告し、代替URLを試す

### 検索結果が期待通りでない

1. 検索ワードを変えて再検索（同義語、英語/日本語切り替え等）
2. 別の検索エンジンを試す（Google → Bing → DuckDuckGo）
3. 3回試してダメならユーザーに報告

### レート制限・ブロック

1. 少し待つ（`browser_wait_for({ time: 5 })`）
2. リロードして再試行
3. それでもダメなら別のアプローチを検討

---

## 情報の整理と報告

調べ物が終わったら、**ブラウザ操作の手順ではなく、調べた内容**をユーザーに報告する。

### 報告テンプレート

```
## 調査結果

[ユーザーの質問に対する回答]

### 詳細

[見つけた情報の要約]

### ソース
- [ページタイトル1](URL1)
- [ページタイトル2](URL2)
```

**悪い例（操作レポート）:**
> navigateでURLを開きました。snapshotを撮りました。スクリーンショットを保存しました。

**良い例（調査結果の報告）:**
> この投稿はTunaさんがClawdbotのClaude Max接続スクリプトを共有したもので、4いいね・6ブックマークを獲得しています。

---

## 初回セットアップ（必須）

**`mcp__playwright__*` ツールが使えない場合、以下を実行すること。**

### セットアップ手順

#### Step 1: Playwright MCPサーバーを登録

**重要: `~/.claude/settings.json` への手動追加ではなく、必ず `claude mcp add` コマンドを使うこと。**

```bash
claude mcp add -s user playwright -- npx -y @playwright/mcp@latest
```

これにより `~/.claude.json` にMCPサーバーが登録される。

**確認:**
```bash
claude mcp list
```
以下のように表示されれば成功:
```
playwright: npx -y @playwright/mcp@latest - Connected
```

#### Step 2: Chromiumをインストール

```bash
npx playwright install chromium
```

#### Step 3: Claude Codeを再起動

MCPサーバーはセッション起動時にのみ読み込まれるため、再起動が必須。

ユーザーに以下を案内すること：
```
Playwright MCPの登録が完了しました。
Claude Codeを再起動してください：
1. Ctrl+C で終了
2. claude で再起動
3. もう一度リクエストを送信

再起動後、ブラウザ操作が使えるようになります。
```

### Claudeが自動実行するセットアップ

このスキルが読み込まれた時に `mcp__playwright__*` ツールが存在しない場合、
以下を Bash で自動実行し、ユーザーに再起動を案内すること：

```bash
claude mcp add -s user playwright -- npx -y @playwright/mcp@latest && npx playwright install chromium
```

### よくある間違い

| 間違い | 正解 |
|--------|------|
| `~/.claude/settings.json` の `mcpServers` に手動追加 | `claude mcp add -s user` コマンドで登録 |
| 登録後すぐにツールを使おうとする | 登録後にClaude Codeを再起動する |
| `npx playwright install` を忘れる | Chromiumのインストールも必要 |

---

## 禁止事項

| 禁止 | 理由 |
|------|------|
| `WebFetch` | JavaScriptが実行されない |
| `WebSearch` | ページ内容を直接見れない |
| `Bash(curl...)` | JavaScriptが実行されない |
| `Bash(wget...)` | JavaScriptが実行されない |
| スクショだけ撮って内容を読まない | 人間はページを読む |
| 1ページだけ見て「見つかりませんでした」と言う | 人間は複数ソースを試す |
| ブラウザ操作の手順を報告する | 人間は調べた内容を伝える |

**必ず `mcp__playwright__*` ツールを使用し、人間と同じように情報を探して伝えること。**
