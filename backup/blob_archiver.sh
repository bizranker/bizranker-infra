#!/bin/bash

# === CONFIG ===
SUDO_PASS_FILE="$HOME/.jenkins_sudo"
ARCHIVE_DIR="/tmp/blob_archives"
BLOBS_DIR="/var/www/html/voximus/blobs"
LOG_FILE="/var/log/blob_archiver.log"
DATE=$(date +'%F')
ARCHIVE_NAME="${ARCHIVE_DIR}/${DATE}_blobs.tar.gz"
S3_BUCKET="s3://usreliance-voximus/blobs_archives"

# === Ensure archive directory exists ===
echo "$(cat $SUDO_PASS_FILE)" | sudo -S mkdir -p "$ARCHIVE_DIR"

# === Logging ===
log() {
    echo "[$(date +'%F %T')] $1" | tee -a "$LOG_FILE"
}

echo "$(cat $SUDO_PASS_FILE)" | sudo -S touch "$LOG_FILE"
echo "$(cat $SUDO_PASS_FILE)" | sudo -S chown "$(whoami)" "$LOG_FILE"

log "📦 Starting blob archive job..."

# === Create tar.gz archive ===
if [ -d "$BLOBS_DIR" ]; then
    tar -czf "$ARCHIVE_NAME" -C "$BLOBS_DIR" .
    if [ $? -eq 0 ]; then
        log "✅ Archive created at $ARCHIVE_NAME"
    else
        log "❌ Failed to create archive"
        exit 1
    fi
else
    log "❌ Blobs directory not found: $BLOBS_DIR"
    exit 1
fi

# === Upload to S3 ===
echo "$(cat $SUDO_PASS_FILE)" | sudo -S aws s3 cp "$ARCHIVE_NAME" "$S3_BUCKET/"
if [ $? -eq 0 ]; then
    log "✅ Archive uploaded to $S3_BUCKET"
else
    log "❌ Failed to upload archive to S3"
    exit 1
fi

log "🎉 Blob archive job complete."

find "$ARCHIVE_DIR" -type f -mtime +14 -name "*.tar.gz" -exec rm {} \;
log "🧹 Pruned local archives older than 14 days."

