#!/bin/bash

DATE=$(date +%Y%m%d)
BUCKET=usreliance-floridasos-backups
DB_NAME=florida_sos
DB_BACKUP="/home/naga/floridasos_backup_${DATE}.sql"
WEB_DIR="/var/www/sos/web/"
FILE_BACKUP="/home/naga/web_backup_${DATE}.tar.gz"

# Dump the FloridaSOS database
mysqldump "$DB_NAME" > "$DB_BACKUP"

# Create differential file archive
rsync -a --delete --link-dest=/home/naga/web_snapshot_last "$WEB_DIR" "/home/naga/web_snapshot_${DATE}"
tar -czf "$FILE_BACKUP" -C /home/naga/ "web_snapshot_${DATE}"

# Upload to S3
aws s3 cp "$DB_BACKUP" s3://$BUCKET/
aws s3 cp "$FILE_BACKUP" s3://$BUCKET/

# Update snapshot symlink
rm -f /home/naga/web_snapshot_last
ln -s "/home/naga/web_snapshot_${DATE}" /home/naga/web_snapshot_last

# Delete backups older than 30 days
find /home/naga/ -name '*.sql' -type f -mtime +30 -delete
find /home/naga/ -name '*.tar.gz' -type f -mtime +30 -delete

# Slack notification
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL_BACKUP}"

if [[ $? -eq 0 ]]; then
  curl -X POST -H 'Content-type: application/json' --data '{"text":"✅ Backup completed successfully on '"$(hostname)"' at '"$(date)"'."}' "$SLACK_WEBHOOK_URL"
else
  curl -X POST -H 'Content-type: application/json' --data '{"text":"❌ Backup failed on '"$(hostname)"' at '"$(date)"'."}' "$SLACK_WEBHOOK_URL"
fi
