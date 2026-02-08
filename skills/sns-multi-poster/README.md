# SNS Multi Poster

5つのSNS（Instagram, Threads, Facebook, Pinterest, X）に画像を自動投稿するスキル。

## ローカル（Mac）でテストする

### 自動同期（推奨）

VPSから最新版を自動ダウンロード：

```bash
# VPSから sync-to-local.sh をダウンロード
scp root@<VPSのIP>:/root/clawd/skills/sns-multi-poster/sync-to-local.sh ~/Downloads/

# 実行権限を付与
chmod +x ~/Downloads/sync-to-local.sh

# VPSのIPを設定して実行
VPS_HOST=<VPSのIP> ~/Downloads/sync-to-local.sh
```

これで `~/.clawdbot/skills/sns-multi-poster/` に最新版が配置されます。

### 手動同期

```bash
scp -r root@<VPSのIP>:/root/clawd/skills/sns-multi-poster ~/.clawdbot/skills/
```

## 使い方

### 基本的な呼び出し
```
SNS投稿
マルチ投稿
```

### 必要な情報
1. 画像パス
2. キャプション
3. Pinterestボード名（オプション、デフォルト: Animal）
4. 投稿先の選択（オプション、デフォルト: 全て）

## 複数アカウント設定

`config.json` を編集してアカウントを追加：

```json
{
  "accounts": {
    "personal": {
      "name": "個人アカウント",
      "instagram": "your_username",
      "x": "your_handle",
      "facebook": "your_id",
      "pinterest": "your_username"
    },
    "business": {
      "name": "ビジネスアカウント",
      "instagram": "business_username",
      "x": "business_handle",
      "facebook": "business_id",
      "pinterest": "business_username"
    }
  }
}
```

### アカウント指定で投稿
```
SNS投稿 (business)
```

## 注意事項

- 初回実行時は各SNSへのログインが必要
- Playwright MCPを使用（ブラウザ自動操作）
- ログイン状態は同一セッション内で維持

詳細は `SKILL.md` を参照。
