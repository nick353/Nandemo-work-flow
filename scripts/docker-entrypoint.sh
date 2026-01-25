#!/bin/bash
set -e

mkdir -p /root/.clawdbot
mkdir -p /root/.clawdbot/agents/main/agent

# Build channels config
DISCORD_CONFIG=""
DISCORD_PLUGIN=""
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
    }'
  DISCORD_PLUGIN='"discord": { "enabled": true }'
  echo "[entrypoint] Discord channel enabled"
fi

# Build auth profiles config
AUTH_PROFILES=""
if [ -n "$ANTHROPIC_API_KEY" ]; then
  AUTH_PROFILES='"anthropic:default": { "provider": "anthropic", "mode": "api_key" }'
  echo "[entrypoint] Anthropic API key configured"

  # Create agent auth profiles file
  cat > /root/.clawdbot/agents/main/agent/auth-profiles.json << EOF
{
  "anthropic:default": {
    "provider": "anthropic",
    "mode": "api_key",
    "apiKey": "$ANTHROPIC_API_KEY"
  }
}
EOF
  echo "[entrypoint] Created auth-profiles.json for agent"
fi

# Create config file based on environment variables
if [ "$CLAWDBOT_NO_AUTH" = "true" ] || [ "$CLAWDBOT_NO_AUTH" = "1" ]; then
  # No authentication mode
  cat > /root/.clawdbot/clawdbot.json << EOF
{
  "gateway": {
    "auth": {
      "mode": "none"
    },
    "controlUi": {
      "enabled": true
    }
  },
  "auth": {
    "profiles": {
      $AUTH_PROFILES
    }
  },
  "channels": {
    $DISCORD_CONFIG
  },
  "plugins": {
    "entries": {
      $DISCORD_PLUGIN
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
    },
    "controlUi": {
      "enabled": true
    }
  },
  "auth": {
    "profiles": {
      $AUTH_PROFILES
    }
  },
  "channels": {
    $DISCORD_CONFIG
  },
  "plugins": {
    "entries": {
      $DISCORD_PLUGIN
    }
  }
}
EOF
  echo "[entrypoint] Created gateway config with token auth"
else
  echo "[entrypoint] No auth config set. Set CLAWDBOT_GATEWAY_TOKEN or CLAWDBOT_NO_AUTH=true"
fi

exec node --max-old-space-size=1024 dist/index.js gateway --bind lan --port 8080 --allow-unconfigured "$@"
