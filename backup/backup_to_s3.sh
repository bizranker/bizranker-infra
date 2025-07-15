#!/bin/bash

set -e  # Exit immediately on error

# Load environment variables
source /home/naga/env/backup.env

# Define vars
DATE=$(date +"%Y%m%d")
DB_NAME="florida_sos"
DB_USER="backupuser"
DB_PASS="S0fttd1al!"

WORKSPACE="/var/lib/jenkins/workspace/bizranker-infra-backup_master"
SNAPSHOT_DIR="${WORKSPACE}/web_snapshot_${DATE}"
DB_BACKUP="${SNAPSHOT_DIR}/${DB_NAME}_${DATE}.sql"
WEB_SNAPSHOT_LAST="${WORKSPACE}/web_snapshot_last"
FILE_BACKUP="${SNAPSHOT_DIR}.tar.gz"
BUCKET="usreliance-floridasos-backups"

# Voximus config
VOXIMUS_DIR="/var/www/html/voximus"
VOXIMUS_ARCHIVE="${WORKSPACE}/voximus_repo_${DATE}.tar.gz"
VOXIMUS_BUCKET="usreliance-voximus"

mkdir -p "$SNAPSHOT_DIR"

echo "🗄️  Dumping MySQL database to $DB_BACKUP"
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$DB_BACKUP"
if [ $? -ne 0 ]; then
  echo "❌ mysqldump failed for $DB_USER"
  exit 1
fi

# Wait briefly for file to flush
for i in {1..5}; do
  [ -f "$DB_BACKUP" ] && echo "✅ SQL dump file ready after $i second(s)" && break
  echo "⏳ Waiting for $DB_BACKUP... ($i/5)"; sleep 1
done

[ ! -f "$DB_BACKUP" ] && echo "❌ SQL dump missing!" && exit 1

echo "📦 Compressing web snapshot"
tar -czf "$FILE_BACKUP" -C "$(dirname "$SNAPSHOT_DIR")" "$(basename "$SNAPSHOT_DIR")"

echo "☁️ Uploading FloridaSOS to S3"
aws s3 cp "$DB_BACKUP" "s3://$BUCKET/"
aws s3 cp "$FILE_BACKUP" "s3://$BUCKET/"

echo "📚 Archiving Voximus Git repo"
tar -czf "$VOXIMUS_ARCHIVE" -C "$(dirname "$VOXIMUS_DIR")" "$(basename "$VOXIMUS_DIR")"

echo "☁️ Uploading Voximus archive to S3"
aws s3 cp "$VOXIMUS_ARCHIVE" "s3://$VOXIMUS_BUCKET/backups/"

echo "🔗 Updating symlink to latest snapshot"
rm -f "$WEB_SNAPSHOT_LAST"
ln -s "$SNAPSHOT_DIR" "$WEB_SNAPSHOT_LAST"

echo "🧹 Pruning old files (>30 days)"
find "$WORKSPACE" -name '*.sql' -type f -mtime +30 -delete
find "$WORKSPACE" -name '*.tar.gz' -type f -mtime +30 -delete

# Slack notify
if [ -n "$SLACK_WEBHOOK_URL_BACKUP" ]; then
  curl -X POST -H "Content-type: application/json" \
    --data "{\"text\":\"✅ Weekly backup complete on $(hostname) at $(date)\"}" \
    "$SLACK_WEBHOOK_URL_BACKUP"
fi

echo "✅ Backup job finished!"

