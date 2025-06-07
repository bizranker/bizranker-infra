# BizRanker Infra

# BizRanker Infrastructure Scripts

This repository contains infrastructure-level automation, backup, monitoring, and alerting scripts used to support the BizRanker platform and related services under the US Reliance organization.

## 📁 Contents

- `backup_to_s3.sh`  
  Automates MySQL + file backup with Slack alerts. Includes rsync-based differentials, S3 upload, cleanup policy, and structured logging.

- `disk_monitor.sh`  
  Daily disk space monitor with warning and critical thresholds, plus Slack alerts.

- `cron/`  
  Crontab-ready entries for `naga` user. Clean, documented, and DevOps-friendly.

- `templates/` *(Coming Soon)*  
  Structured templates for provisioning, scaling, and multi-server orchestration.

---

## 🔧 Requirements

- AWS CLI (`aws configure`)
- Slack Incoming Webhook
- `.my.cnf` configured for MySQL root access (for non-interactive backups)
- Proper IAM permissions for S3 access

---

## 🔔 Alerts

- Slack alerts are sent to relevant channels for:
  - Backup success or failure (`#backup-alerts`)
  - Disk usage thresholds (`#infra-alerts`)

---

## 🧠 Best Practices

- Keep all backup logic within `/usr/local/bin` on `usreliance.com`
- Use dedicated crontab under `naga`
- Store Git-managed infra under:  
  `/home/naga/repos/bizranker-infra` *(symbolically linked if necessary)*

---

## 🧱 Architecture Alignment

All automation supports:
- 🔐 **Separation of concerns**
- 🧪 **Auditability**
- 🛰️ **Remote recovery via GitHub repo**

For setup or assistance, reach out via Slack in `#infra-alerts` or DM `@BrianBills`.

---
