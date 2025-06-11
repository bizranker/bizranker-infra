#!/bin/bash

set -e  # Exit immediately on error

# Load environment variables
source /home/naga/repos/bizranker-infra/.env

# Define vars
DATE=$(date +"%Y%m%d")
DB_NAME="florida_sos"
DB_USER="backupuser"
DB_PASS="S0fttd1al!"
DB_BACKUP="/home/naga/web_snapshot_${DATE}/${DB_NAME}_${DATE}.sql"
WEB_DIR="/home/naga/web"
SNAPSHOT_DIR="/home/naga/web_snapshot_${DATE}"
WEB_SNAPSHOT_LAST="/home/naga/web_snapshot_last"
BUCKET="usreliance-floridasos-backups"

# Create snapshot directory
mkdir -p "$SNAPSHOT_DIR"

# Dump the database securely
echo "🗄️  Dumping MySQL database to $DB_BACKUP"
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$DB_BACKUP"
if [ $? -ne 0 ]; then
  echo "❌ mysqldump failed for user $DB_USER. Aborting."
  exit 1
fi

# Wait up to 5 seconds for SQL dump file to appear
for i in {1..5}; do
  if [ -f "$DB_BACKUP" ]; then
    break
  fi
  echo "⏳ Waiting for $DB_BACKUP to finish writing..."
  sleep 1
done

# Final check if still missing
if [ ! -f "$DB_BACKUP" ]; then
  echo "❌ SQL dump file $DB_BACKUP was not found. Aborting compression."
  exit 1
fi

# Rsync the current web directory
echo "📁 Syncing web directory to $SNAPSHOT_DIR"
rsync -a --delete --link-dest="$WEB_SNAPSHOT_LAST" "$WEB_DIR/" "$SNAPSHOT_DIR"

# Compress the snapshot
FILE_BACKUP="${SNAPSHOT_DIR}.tar.gz"
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

# Clean up old backups
echo "🧹 Deleting backups older than 30 days"
find /home/naga/ -name '*.sql' -type f -mtime +30 -delete
find /home/naga/ -name '*.tar.gz' -type f -mtime +30 -delete

# Send Slack notification
if [ -n "$SLACK_WEBHOOK_URL_BACKUP" ]; then
  echo "📣 Sending Slack notification"
  curl -X POST -H "Content-type: application/json" \
    --data "{\"text\":\"✅ Backup completed successfully on $(hostname) at $(date)\"}" \
    "$SLACK_WEBHOOK_URL_BACKUP"
fi

echo "✅ All backup steps completed successfully."
