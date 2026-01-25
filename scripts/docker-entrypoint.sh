#!/bin/bash
set -e

mkdir -p /root/.clawdbot

# Create config file based on environment variables
if [ "$CLAWDBOT_NO_AUTH" = "true" ] || [ "$CLAWDBOT_NO_AUTH" = "1" ]; then
  # No authentication mode
  cat > /root/.clawdbot/clawdbot.json << EOF
{
  "gateway": {
    "auth": {
      "mode": "none"
    }
  }
}
EOF
  echo "[entrypoint] Created gateway config with NO auth (public access)"
elif [ -n "$CLAWDBOT_GATEWAY_TOKEN" ]; then
  # Token authentication mode
  cat > /root/.clawdbot/clawdbot.json << EOF
{
  "gateway": {
    "auth": {
      "mode": "token",
      "token": "$CLAWDBOT_GATEWAY_TOKEN"
    }
  }
}
EOF
  echo "[entrypoint] Created gateway config with token auth"
else
  echo "[entrypoint] No auth config set. Set CLAWDBOT_GATEWAY_TOKEN or CLAWDBOT_NO_AUTH=true"
fi

exec node --max-old-space-size=1024 dist/index.js gateway --bind lan --port 8080 --allow-unconfigured "$@"
