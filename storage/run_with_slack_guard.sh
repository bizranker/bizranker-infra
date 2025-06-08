#!/bin/bash

LOGFILE="/var/log/disk_alerts.log"
SCRIPT="/home/naga/repos/bizranker-infra/storage/disk_monitor.sh"
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"
HOST=$(hostname)

bash "$SCRIPT"
STATUS=$?

if [ $STATUS -ne 0 ]; then
    MSG="🔥 *FAILURE on ${HOST}*: disk_monitor.sh exited with code $STATUS"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${MSG}" >> "$LOGFILE"
    curl -X POST -H 'Content-type: application/json' \
         --data "{\"text\":\"${MSG}\"}" "$SLACK_WEBHOOK_URL"
fi

