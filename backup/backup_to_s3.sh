#!/bin/bash

set -e  # Exit immediately on error

# Load environment variables
source /opt/usreliance/env/backup.env

# Define vars
DATE=$(date +"%Y%m%d")
DB_NAME="florida_sos"
DB_USER="backupuser"
DB_PASS="S0fttd1al!"

# Use Jenkins workspace as base
WORKSPACE="/var/lib/jenkins/workspace/bizranker-infra-backup_master"
SNAPSHOT_DIR="${WORKSPACE}/web_snapshot_${DATE}"
DB_BACKUP="${SNAPSHOT_DIR}/${DB_NAME}_${DATE}.sql"
WEB_DIR="${WORKSPACE}/web"
WEB_SNAPSHOT_LAST="${WORKSPACE}/web_snapshot_last"
FILE_BACKUP="${SNAPSHOT_DIR}.tar.gz"
BUCKET="usreliance-floridasos-backups"

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"

# Dump the database
echo "🗄️  Dumping MySQL database to $DB_BACKUP"
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$DB_BACKUP"
if [ $? -ne 0 ]; then
  echo "❌ mysqldump failed for user $DB_USER. Aborting."
  exit 1
fi

# Wait for SQL dump to appear
for i in {1..5}; do
  if [ -f "$DB_BACKUP" ]; then
    echo "✅ SQL dump file $DB_BACKUP detected after $i second(s)."
    break
  else
    echo "⏳ Waiting for $DB_BACKUP to finish writing... ($i/5)"
    sleep 1
  fi
done

# Final check
if [ ! -f "$DB_BACKUP" ]; then
  echo "❌ SQL dump file $DB_BACKUP was not found. Aborting compression."
  exit 1
fi

# Compress the snapshot
echo "📦 Compressing snapshot to $FILE_BACKUP"
tar -czf "$FILE_BACKUP" -C "$(dirname "$SNAPSHOT_DIR")" "$(basename "$SNAPSHOT_DIR")"

# Upload to S3
echo "☁️ Uploading files to S3 bucket $BUCKET"
aws s3 cp "$DB_BACKUP" "s3://$BUCKET/"
aws s3 cp "$FILE_BACKUP" "s3://$BUCKET/"

# Update snapshot symlink
echo "🔗 Updating snapshot symlink"
rm -f "$WEB_SNAPSHOT_LAST"
ln -s "$SNAPSHOT_DIR" "$WEB_SNAPSHOT_LAST"

# Clean up old backups in workspace
echo "🧹 Deleting backups older than 30 days"
find "$WORKSPACE" -name '*.sql' -type f -mtime +30 -delete
find "$WORKSPACE" -name '*.tar.gz' -type f -mtime +30 -delete

# Send Slack notification
if [ -n "$SLACK_WEBHOOK_URL_BACKUP" ]; then
  echo "📣 Sending Slack notification"
  curl -X POST -H "Content-type: application/json" \
    --data "{\"text\":\"✅ Backup completed successfully on $(hostname) at $(date)\"}" \
    "$SLACK_WEBHOOK_URL_BACKUP"
fi

echo "✅ All backup steps completed successfully."
