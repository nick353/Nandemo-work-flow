#!/bin/bash
set -e

mkdir -p /root/.clawdbot

# Build channels config
DISCORD_CONFIG=""
if [ -n "$DISCORD_BOT_TOKEN" ]; then
  DISCORD_CONFIG='"discord": {
      "enabled": true,
      "token": "'"$DISCORD_BOT_TOKEN"'",
      "dm": {
        "enabled": true,
        "policy": "open",
        "allowFrom": ["*"]
      },
      "groupPolicy": "open"
    },'
  echo "[entrypoint] Discord channel enabled"
fi

# Create config file based on environment variables
if [ "$CLAWDBOT_NO_AUTH" = "true" ] || [ "$CLAWDBOT_NO_AUTH" = "1" ]; then
  # No authentication mode - open webchat access
  cat > /root/.clawdbot/clawdbot.json << EOF
{
  "gateway": {
    "auth": {
      "mode": "none"
    }
  },
  "channels": {
    $DISCORD_CONFIG
    "webchat": {
      "enabled": true,
      "policy": "open"
    }
  }
}
EOF
  echo "[entrypoint] Created gateway config with NO auth (public access)"
elif [ -n "$CLAWDBOT_GATEWAY_TOKEN" ]; then
  # Token authentication mode with open webchat
  cat > /root/.clawdbot/clawdbot.json << EOF
{
  "gateway": {
    "auth": {
      "mode": "token",
      "token": "$CLAWDBOT_GATEWAY_TOKEN"
    }
  },
  "channels": {
    $DISCORD_CONFIG
    "webchat": {
      "enabled": true,
      "policy": "open"
    }
  }
}
EOF
  echo "[entrypoint] Created gateway config with token auth + open webchat"
else
  echo "[entrypoint] No auth config set. Set CLAWDBOT_GATEWAY_TOKEN or CLAWDBOT_NO_AUTH=true"
fi

exec node --max-old-space-size=1024 dist/index.js gateway --bind lan --port 8080 --allow-unconfigured "$@"
