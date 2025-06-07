#!/bin/bash

THRESHOLD_WARN=70
THRESHOLD_CRIT=85
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"
LOGFILE="/var/log/disk_alerts.log"
HOST=$(hostname)

df -h --output=pcent,target | grep -v Use | while read line; do
    USAGE=$(echo "$line" | awk '{print $1}' | tr -d '%')
    MOUNT=$(echo "$line" | awk '{print $2}')

    if (( USAGE >= THRESHOLD_CRIT )); then
        MSG="🚨 *<@channel> CRITICAL on ${HOST}:* Disk usage at ${USAGE}% on ${MOUNT}"
    elif (( USAGE >= THRESHOLD_WARN )); then
        MSG="⚠️ WARNING on ${HOST}: Disk usage at ${USAGE}% on ${MOUNT}"
    else
        MSG="✅ OK on ${HOST}: Disk usage at ${USAGE}% on ${MOUNT}"
    fi

    # Log message
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${MSG}" >> "$LOGFILE"

    # Send to Slack
    curl -X POST -H 'Content-type: application/json' \
         --data "{\"text\":\"${MSG}\"}" "$SLACK_WEBHOOK_URL"
done

