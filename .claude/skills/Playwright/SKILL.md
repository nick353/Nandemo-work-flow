---
name: playwright-actions
description: |
  Playwright MCPでブラウザ操作を行うスキル。

  **このスキルは以下の場合に自動的に使用されます：**
  - URLが含まれるリクエスト（https://、http://）
  - Webページの閲覧・確認が必要なリクエスト
  - X/Twitter、SPAなどJavaScriptが必要なサイトへのアクセス

  WebFetchやWebSearchではなく、必ずPlaywright MCPを使用すること。

triggers:
  # URL patterns - URLが含まれていたら自動でPlaywrightを使う
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
  - スクロールして
  - スクショ
  - スクリーンショット

  # Natural language - English
  - open this
  - check this
  - visit
  - browse
  - look at
  - research
  - scroll
  - screenshot
---

# Playwright Actions スキル

**URLが渡されたら、自動的にPlaywright MCPでブラウザを開きます。**

---

## 🔧 初回セットアップ（必須）

**このスキルを使用する前に、以下のセットアップが必要です。**

### Step 1: MCP設定を追加

`~/.claude/settings.json` に以下を追加：

```json
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest"]
    }
  }
}
```

**または、以下のコマンドを実行：**

```bash
node -e "
const fs = require('fs');
const path = require('path');
const settingsPath = path.join(process.env.HOME, '.claude', 'settings.json');
let settings = {};
if (fs.existsSync(settingsPath)) {
  settings = JSON.parse(fs.readFileSync(settingsPath, 'utf8'));
}
if (!settings.mcpServers) settings.mcpServers = {};
if (!settings.mcpServers.playwright) {
  settings.mcpServers.playwright = {
    type: 'stdio',
    command: 'npx',
    args: ['-y', '@playwright/mcp@latest']
  };
  fs.writeFileSync(settingsPath, JSON.stringify(settings, null, 2));
  console.log('✅ Playwright MCP設定を追加しました');
} else {
  console.log('✅ Playwright MCP設定は既に存在します');
}
"
```

### Step 2: Chromiumをインストール

```bash
npx playwright install chromium
```

### Step 3: Claude Codeを再起動（重要！）

```
1. Ctrl+C でClaude Codeを終了
2. claude で再起動
```

**⚠️ 再起動しないとMCPサーバーは接続されません！**

### Step 4: 接続確認

再起動後、以下のツールが使えることを確認：
- `mcp__playwright__browser_navigate`
- `mcp__playwright__browser_snapshot`
- `mcp__playwright__browser_take_screenshot`

**ツールが見つからない場合は、Step 1-3を再確認してください。**

---

## ⚠️ 絶対ルール（最重要）

### このスキルが読み込まれたら：

1. **URLが含まれている → Playwright MCPで開く**
2. **WebFetch/WebSearchは使わない**
3. **Bashでcurlやwgetは使わない**

### 必ず使うツール：
```
mcp__playwright__browser_navigate  → URLを開く
mcp__playwright__browser_snapshot  → ページ内容を取得
mcp__playwright__browser_take_screenshot → スクリーンショット
mcp__playwright__browser_wait_for  → 待機
```

---

## 自動実行フロー

**ユーザーがURLを含むリクエストをしたら、以下を自動実行：**

### Step 1: ブラウザ準備
```
mcp__playwright__browser_install({})
```

### Step 2: URLを開く
```
mcp__playwright__browser_navigate({ url: "<ユーザーが渡したURL>" })
```

### Step 3: 読み込み待機
```
mcp__playwright__browser_wait_for({ time: 3 })
```

### Step 4: 内容取得
```
mcp__playwright__browser_snapshot({})
```

### Step 5: スクリーンショット
```
mcp__playwright__browser_take_screenshot({ filename: "page.png", type: "png" })
```

---

## 使用例

### 例1: URLだけ渡された場合

**ユーザー:** `https://x.com/user/status/123`

**実行:**
```
mcp__playwright__browser_install({})
mcp__playwright__browser_navigate({ url: "https://x.com/user/status/123" })
mcp__playwright__browser_wait_for({ time: 3 })
mcp__playwright__browser_snapshot({})
mcp__playwright__browser_take_screenshot({ filename: "page.png", type: "png" })
```

### 例2: 自然な言い方

**ユーザー:** 「このURL見て https://example.com」

**実行:** 同上

### 例3: 複数URL

**ユーザー:** 「https://a.com と https://b.com を調べて」

**実行:**
```
// 1つ目
mcp__playwright__browser_navigate({ url: "https://a.com" })
mcp__playwright__browser_wait_for({ time: 3 })
mcp__playwright__browser_snapshot({})
mcp__playwright__browser_take_screenshot({ filename: "page1.png" })

// 2つ目
mcp__playwright__browser_navigate({ url: "https://b.com" })
mcp__playwright__browser_wait_for({ time: 3 })
mcp__playwright__browser_snapshot({})
mcp__playwright__browser_take_screenshot({ filename: "page2.png" })
```

---

## その他のコマンド

### スクロール
```
/scroll down  → mcp__playwright__browser_press_key({ key: "PageDown" })
/scroll up    → mcp__playwright__browser_press_key({ key: "PageUp" })
/scroll top   → mcp__playwright__browser_evaluate({ function: "() => window.scrollTo(0, 0)" })
/scroll bottom → mcp__playwright__browser_evaluate({ function: "() => window.scrollTo(0, document.body.scrollHeight)" })
```

### 要素操作
```
/get-text <ref> → mcp__playwright__browser_evaluate({ function: "(el) => el.textContent", ref: "<ref>", element: "要素" })
/get-url        → mcp__playwright__browser_evaluate({ function: "() => location.href" })
/get-title      → mcp__playwright__browser_evaluate({ function: "() => document.title" })
```

### クリック
```
mcp__playwright__browser_click({ element: "ボタン", ref: "<ref>" })
```

### 入力
```
mcp__playwright__browser_type({ element: "入力欄", ref: "<ref>", text: "テキスト" })
```

---

## 禁止事項（重要）

以下のツールは**絶対に使わないこと**：

| 禁止 | 理由 |
|------|------|
| `WebFetch` | JavaScriptが実行されない |
| `WebSearch` | ページ内容を直接見れない |
| `Bash(curl...)` | JavaScriptが実行されない |
| `Bash(wget...)` | JavaScriptが実行されない |

**必ず `mcp__playwright__*` ツールを使用すること。**

---

## 🔍 トラブルシューティング

### 「No such tool available: mcp__playwright__*」エラー

**原因：** MCPサーバーが接続されていない

**解決策：**
1. `~/.claude/settings.json` に `playwright` MCPが設定されているか確認
2. `npx playwright install chromium` を実行
3. **Claude Codeを再起動**（これが最も重要！）

### ブラウザが起動しない

**解決策：**
```bash
# Playwrightの依存関係を再インストール
npx playwright install --with-deps chromium
```

### タイムアウトエラー

**解決策：**
```bash
# 待機時間を増やす
mcp__playwright__browser_wait_for({ time: 5 })
```

### 設定ファイルの場所

| OS | パス |
|----|------|
| macOS/Linux | `~/.claude/settings.json` |
| Windows | `%USERPROFILE%\.claude\settings.json` |

### 設定確認コマンド

```bash
cat ~/.claude/settings.json | grep -A5 playwright
```

正しく設定されていれば以下が表示される：
```json
"playwright": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@playwright/mcp@latest"]
}
```
