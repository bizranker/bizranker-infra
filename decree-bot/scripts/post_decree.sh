#!/bin/sh
curl -X POST -H 'Content-type: application/json' --data @/app/decrees/$1 https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
