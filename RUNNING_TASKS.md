# RUNNING_TASKS.md - 実行中タスク

## 現在実行中

- **[2026-02-09 06:30]** github-mcp-server インストール
  - 作業ディレクトリ: /root/clawd
  - コマンド: `npm install -g @modelcontextprotocol/server-github`
  - セッションID: plaid-glade
  - 目的: GitHub MCP サーバーをグローバルインストール
  - 開始報告: 済

## 完了済み

- **[2026-02-09 03:47-03:48]** Google Cookieインポート ✅ 成功
  - コマンド: `/tmp/import-cookies-v2.sh`
  - セッションID: rapid-slug
  - 結果: 20個のCookie設定完了、Google Sheetsログイン成功（VPS完結のWeb自動化実現）

- **[2026-02-09 02:15]** Chromiumインストール
  - 作業ディレクトリ: /root/clawd
  - コマンド: `apt-get update && apt-get install -y chromium chromium-driver`
  - セッションID: oceanic-canyon
  - 目的: 浮世絵猫転記スキル（browser tool）を使うため
  - 完了: 2026-02-09 02:16（ハートビート時検知）

- **[2026-02-09 01:47]** pnpm install (sns-multi-poster) - **未実行（記録ミス）**
  - package.jsonが存在しないため実行されていなかった

---

## テンプレート（タスク記録時に使用）

```
- **[YYYY-MM-DD HH:MM]** <コマンド概要>
  - 作業ディレクトリ: /path/to/dir
  - コマンド: `<実際のコマンド>`
  - セッションID: <session-id>
  - 目的: <何のため>
  - 開始報告: 済/未
```

---

**厳守ルール：**
1. タスク開始時：必ずテンプレートに従って記録
2. タスク完了時：「完了済み」に移動（結果を明記）
3. 質問を受けた時：まず `process list` → このファイル の順で確認
4. ハートビート時：自動チェック＆更新
5. 約束を守る：「完了したら報告する」と言ったら必ず報告
