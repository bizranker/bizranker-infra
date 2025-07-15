#!/bin/bash

# === CONFIG ===
SUDO_PASS_FILE="$HOME/.jenkins_sudo"
JENKINS_WAR="/usr/share/jenkins/jenkins.war"
BACKUP_DIR="/opt/jenkins_war_backups"
TMP_WAR="/tmp/jenkins-latest.war"
DOWNLOAD_URL="https://get.jenkins.io/war-stable/latest/jenkins.war"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SYSTEMD_SERVICE="jenkins"

# === SANITY CHECK ===
if [[ ! -f "$SUDO_PASS_FILE" ]]; then
  echo "❌ Sudo password file not found: $SUDO_PASS_FILE"
  exit 1
fi

SUDO_PASS=$(<"$SUDO_PASS_FILE")

# === BACKUP ===
echo "📦 Backing up current WAR..."
echo "$SUDO_PASS" | sudo -S mkdir -p "$BACKUP_DIR"
echo "$SUDO_PASS" | sudo -S cp "$JENKINS_WAR" "$BACKUP_DIR/jenkins.war.backup.$TIMESTAMP"

# === DOWNLOAD ===
echo "🌐 Downloading latest Jenkins WAR..."
curl -L -o "$TMP_WAR" "$DOWNLOAD_URL"

if [[ ! -f "$TMP_WAR" ]]; then
    echo "❌ Failed to download WAR."
    exit 1
fi

# === INSTALL ===
echo "🔁 Replacing current WAR..."
echo "$SUDO_PASS" | sudo -S cp "$TMP_WAR" "$JENKINS_WAR"
echo "$SUDO_PASS" | sudo -S chown jenkins:jenkins "$JENKINS_WAR"

# === RESTART ===
echo "🚀 Restarting Jenkins..."
echo "$SUDO_PASS" | sudo -S systemctl restart "$SYSTEMD_SERVICE"

echo "✅ Done!"

