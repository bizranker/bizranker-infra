#!/bin/bash

MESSAGE="$1"
COLOR="${2:-good}"  # Default to green
WEBHOOK_URL=$(grep '^SLACK_WEBHOOK_URL=' /home/naga/.env | cut -d '=' -f2-)

if [[ -z "$WEBHOOK_URL" ]]; then
  echo "❌ SLACK_WEBHOOK_URL not set or missing in /home/naga/.env"
  exit 1
fi

payload="{
  \"attachments\": [{
    \"fallback\": \"$MESSAGE\",
    \"color\": \"$COLOR\",
    \"text\": \"$MESSAGE\"
  }]
}"

curl -s -X POST -H 'Content-type: application/json' --data "$payload" "$WEBHOOK_URL"

