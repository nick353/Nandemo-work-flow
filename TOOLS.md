# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases  
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## 🔧 andoさん環境の設定

### X (Twitter) リサーチ
- **CLI**: `bird` (@steipete/bird)
- **インストール済み**: ✅ `/root/.npm-global/lib/node_modules/@steipete/bird`
- **認証**: 未設定（要クッキー設定）
  - 必要: `AUTH_TOKEN`, `CT0` 環境変数
  - 設定先: `~/.profile` or `~/.config/bird/config.json5`
- **用途**: トレンド調査、ツール評判確認、リアルタイム情報収集

### 動画処理（計画中）
- **音声改善**: Adobe Podcast Enhance（Web API/手動）
- **高画質化**: 
  - Runway ML API（検討中、月$12〜）
  - または ffmpeg 高品質エンコード（無料、GPU不要）
- **字幕**: OpenAI Whisper（手動追加想定）
- **投稿**: sns-multi-poster スキル使用

### VPS環境
- **場所**: Zeabur（ボリューム永続化: /root/clawd）
- **GPU**: なし（AI upscaling 制限あり）
- **Node**: v22.22.0
- **自動バックアップ**: GitHub（scripts/backup-with-retry.sh）

---

Add whatever helps you do your job. This is your cheat sheet.
