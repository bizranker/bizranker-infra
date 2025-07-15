#!/bin/bash

# Load env vars
source ~/.env

# Variables
WEBHOOK_URL="$SLACK_WEBHOOK_URL"
REPO_DIR="/home/naga/repos/bizranker-infra"
LOG_FILE="$REPO_DIR/notify/slack_notify.log"

cd "$REPO_DIR" || exit 1

# Git details
BRANCH=$(git rev-parse --abbrev-ref HEAD)
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MESSAGE=$(git log -1 --pretty=%B)

# Timestamp
TIME=$(date +"%Y-%m-%d %H:%M:%S")

# Build payload
read -r -d '' PAYLOAD <<EOF
{
  "username": "ButabiBot",
  "icon_emoji": ":rocket:",
  "channel": "#monita-fortuna",
  "attachments": [
    {
      "fallback": "Deployment Notification",
      "color": "#36a64f",
      "pretext": "*🚀 Deployment Notification — slack_notify.sh*",
      "fields": [
        {
          "title": "Status",
          "value": "✅ Success",
          "short": true
        },
        {
          "title": "Branch",
          "value": "$BRANCH",
          "short": true
        },
        {
          "title": "Commit",
          "value": "\`$COMMIT_HASH\`",
          "short": false
        },
        {
          "title": "Message",
          "value": "$COMMIT_MESSAGE",
          "short": false
        },
        {
          "title": "Timestamp",
          "value": "$TIME",
          "short": true
        }
      ],
      "footer": "US Reliance :: Voximus Ops",
      "ts": $(date +%s)
    }
  ]
}
EOF

# Send to Slack
curl -X POST -H 'Content-type: application/json' --data "$PAYLOAD" "$WEBHOOK_URL" && \
echo "[$TIME] Slack message with Git info sent successfully." >> "$LOG_FILE"

