# MEMORY.md - 記憶の中心

> このファイルは、重要な情報・決定事項・進行中のプロジェクトをまとめる場所です。
> 日付ごとの詳細は `memory/*.md` に保存されます。

---

## 🧑 andoさんについて
- Discord: ando3380
- GitHub: nick353
- VPS: Zeabur（ボリューム: `/root/clawd`）
- タイムゾーン: 日本（推定）
- 好み: 自動化・効率化・記憶の永続化を重視

---

## 📌 現在進行中のプロジェクト

### 1. 記憶システムの改善
**目的:** チャット内容を忘れないようにする  
**アプローチ:**
- [x] 既存メモリ確認（memory/2026-01-27.md発見）
- [ ] MEMORY.md作成（このファイル）
- [ ] memory_searchの動作確認
- [ ] ClawdHubでメモリ管理Skillを探す
- [ ] MCP Memory Serverの導入検討
- [ ] 自動サマリー生成cronを設定

**関連ファイル:**
- `memory/2026-01-27.md` - 過去のセットアップ記録
- `IDENTITY.md` - リッキーのアイデンティティ
- `USER.md` - andoさんの情報
- `HEARTBEAT.md` - 自動タスク定義

---

## 🔗 重要なリポジトリ
- **本家:** https://github.com/nick353/Nandemo-work-flow
- **バックアップ:** https://github.com/nick353/save-point

---

## ⚙️ システム設定

### Clawdbot設定
- `tools.exec.ask: "off"` - コマンド承認なしで実行可能
- GitHubリポジトリ復元済み
- 自動バックアップスクリプト: `/root/clawd/scripts/backup-with-retry.sh`

### 過去の問題
- Zeaburボリューム追加時に設定がリセットされた（2026-01-27）
- OAuthエラーでセッション終了（前回のリッキー）

### 解決策
- ボリュームマウント: `/root/clawd` を永続化
- 設定バックアップ: `.clawdbot-backup/` 配下に保存

---

## 📚 学んだこと・決定事項

### 2026-01-27
- Zeaburでボリュームを追加するとワークスペースがリセットされる
- GitHubからの復元が有効な対策
- memory/ディレクトリで日付ごとに記録を管理

### 2026-02-09
- 記憶の問題について相談を受けた
- 順番に対策を試していく方針
- まずはMEMORY.mdを作成して構造化

---

## 🔄 定期タスク（HEARTBEAT.md参照）
- 自動バックアップ: `backup-with-retry.sh`
- ヘルスチェック: `health-check.sh`
- プロセス監視: RUNNING_TASKS.md照合

---

**最終更新:** 2026-02-09  
**更新者:** リッキー 🦜
