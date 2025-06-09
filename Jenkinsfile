pipeline {
    agent any

    environment {
        BUCKET = 'usreliance-floridasos-backups'
        DB_NAME = 'florida_sos'
        DATE = "${new Date().format('yyyyMMdd')}"
        SNAPSHOT_DIR = "/var/lib/jenkins/backups/web_snapshot_${DATE}"
        DB_BACKUP = "${SNAPSHOT_DIR}/${DB_NAME}_${DATE}.sql"
        FILE_BACKUP = "${SNAPSHOT_DIR}.tar.gz"
        WEB_DIR = "/var/www/html/demo"  // adjust if needed
        WEB_SNAPSHOT_LAST = "/var/lib/jenkins/backups/web_snapshot_last"
        SLACK_WEBHOOK = credentials('slack-webhook-backup')
    }

    options {
        timestamps()
    }

    stages {
        stage('Prepare Snapshot Folder') {
            steps {
                sh "mkdir -p ${SNAPSHOT_DIR}"
            }
        }

        stage('MySQL Dump') {
        withCredentials([usernamePassword(credentialsId: 'mysql-backup-creds', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASS')]) {
            sh '''
                echo "📦 Dumping MySQL database..."
                mysqldump -h 127.0.0.1 -u $DB_USER -p$DB_PASS $DB_NAME > $DB_BACKUP || {
                  echo "❌ mysqldump failed, aborting backup"
                  exit 1
                }
            '''
        }
    }
            }
        }

        stage('Rsync Web Directory') {
            steps {
                sh "rsync -a --delete --link-dest='${WEB_SNAPSHOT_LAST}' '${WEB_DIR}/' '${SNAPSHOT_DIR}'"
            }
        }

        stage('Compress Snapshot') {
            steps {
                sh "tar -czf '${FILE_BACKUP}' -C \$(dirname '${SNAPSHOT_DIR}') \$(basename '${SNAPSHOT_DIR}')"
            }
        }

        stage('Upload to S3') {
            steps {
                sh """
                    aws s3 cp '${DB_BACKUP}' 's3://${BUCKET}/'
                    aws s3 cp '${FILE_BACKUP}' 's3://${BUCKET}/'
                """
            }
        }

        stage('Update Snapshot Symlink') {
            steps {
                sh """
                    rm -f '${WEB_SNAPSHOT_LAST}'
                    ln -s '${SNAPSHOT_DIR}' '${WEB_SNAPSHOT_LAST}'
                """
            }
        }

        stage('Delete Old Backups') {
            steps {
                sh """
                    find /var/lib/jenkins/backups/ -name '*.sql' -type f -mtime +30 -delete
                    find /var/lib/jenkins/backups/ -name '*.tar.gz' -type f -mtime +30 -delete
                """
            }
        }

        stage('Slack Notification') {
            steps {
                sh """
                    curl -X POST -H "Content-type: application/json" \\
                    --data '{\"text\":\"✅ Backup completed successfully on \$(hostname) at \$(date)\"}' \\
                    "\$SLACK_WEBHOOK"
                """
            }
        }
    }
}
