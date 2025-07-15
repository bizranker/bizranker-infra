# BizRanker Infra

> *Infrastructure that never flinches.*

This repository contains infrastructure-level automation, backup, monitoring, and deployment scripts supporting the BizRanker platform and related services under the US Reliance umbrella.

---

## 📁 Contents

- `backup_to_s3.sh`  
  Automates full MySQL and web backup to S3 with Slack alerts. Includes rsync, timestamping, cleanup policy, and detailed logging.

- `disk_monitor.sh`  
  Disk space monitor with warning/critical thresholds and Slack notifications via `#monita-thesaurorum`.

- `update_war.sh`  
  Automates Jenkins `.war` file updates. Backs up the old WAR, downloads the latest version, replaces the current file, and restarts Jenkins. Pulls the sudo password from a secure locked file (`.jenkins_sudo`).

- `alerts/`  
  Slack integration samples and webhook formats.

- `storage/`  
  Disk usage logic, capacity planning tools.

- `backup/`  
  Default backup staging and log directory.

---

## 🔧 Requirements

- AWS CLI (`aws configure`)
- Slack webhook credentials
- `.my.cnf` file for MySQL non-interactive login
- `.jenkins_sudo` file under `~/` containing the user’s sudo password (chmod 600)

---

## ⚠️ Sudo Access & Security

To avoid interactive password prompts, the Jenkins WAR updater script uses:
```bash
~/.jenkins_sudo
This file must contain your sudo password in plain text and be:

bash
Copy
Edit
chmod 600 ~/.jenkins_sudo
Warning: Only use this on hardened servers with controlled access. Never commit this file to Git.

🧠 Best Practices
Store Git-managed infra here:
/home/naga/repos/bizranker-infra

Schedule all cron jobs under the naga user

Keep operational scripts (update_war.sh, backup_to_s3.sh) executable

Slack alerts route to #monita-fortuna, #monita-thesaurorum, and other Roman-themed channels

🧱 Architecture Pillars
🛰️ Remote Recovery via GitHub Actions or SSH

🔐 Minimal Privilege Access with sealed credentials

🏗️ Modular Layout for backups, alerts, deploys

For onboarding, ping @BrianBills in Slack or hail #operati-consilium.

"Backup. Rebuild. Rise Again." — Voximus
