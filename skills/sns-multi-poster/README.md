# SNS Multi Poster

5つのSNS（Instagram, Threads, Facebook, Pinterest, X）に画像を自動投稿するスキル。

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
