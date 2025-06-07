#!/bin/bash

THRESHOLD_WARN=70
THRESHOLD_CRIT=80
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"

while read line; do
    USAGE=$(echo "$line" | awk '{print $5}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $6}')
    if (( USAGE >= THRESHOLD_CRIT )); then
        MSG="🚨 CRITICAL: Disk usage at ${USAGE}% on ${MOUNT}"
    elif (( USAGE >= THRESHOLD_WARN )); then
        MSG="⚠️ WARNING: Disk usage at ${USAGE}% on ${MOUNT}"
    else
        MSG="✅ OK: Disk usage at ${USAGE}% on ${MOUNT}"
    fi
    curl -X POST -H 'Content-type: application/json' --data "{"text":"${MSG}"}" "$SLACK_WEBHOOK_URL"
done < <(df -h --output=pcent,target | grep -v Use)
