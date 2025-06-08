#!/bin/bash

set -e  # Stop on any error

# Load environment variables
source /home/naga/repos/bizranker-infra/.env

# Define vars
DATE=$(date +"%Y%m%d")
DB_NAME="floridasos"
DB_BACKUP="/home/naga/web_snapshot_${DATE}/${DB_NAME}_${DATE}.sql"
WEB_DIR="/home/naga/web"
SNAPSHOT_DIR="/home/naga/web_snapshot_${DATE}"
WEB_SNAPSHOT_LAST="/home/naga/web_snapshot_last"
BUCKET="usreliance-floridasos-backups"

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"

# Dump the database
mysqldump "$DB_NAME" > "$DB_BACKUP"

# Create differential file archive
rsync -a --delete --link-dest="$WEB_SNAPSHOT_LAST" "$WEB_DIR/" "$SNAPSHOT_DIR"

# Compress the snapshot
FILE_BACKUP="${SNAPSHOT_DIR}.tar.gz"
tar -czf "$FILE_BACKUP" -C "$(dirname "$SNAPSHOT_DIR")" "$(basename "$SNAPSHOT_DIR")"

# Upload to S3
aws s3 cp "$DB_BACKUP" "s3://$BUCKET/"
aws s3 cp "$FILE_BACKUP" "s3://$BUCKET/"

# Update snapshot symlink
rm -f "$WEB_SNAPSHOT_LAST"
ln -s "$SNAPSHOT_DIR" "$WEB_SNAPSHOT_LAST"

# Delete old backups
find /home/naga/ -name '*.sql' -type f -mtime +30 -delete
find /home/naga/ -name '*.tar.gz' -type f -mtime +30 -delete

# Slack Notification
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"✅ Backup completed successfully on '"$(hostname)"' at '"$(date)"'"}' \
  "$SLACK_WEBHOOK_URL_BACKUP"

