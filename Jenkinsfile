pipeline {
    agent any
    environment {
        DATE = """${new Date().format('yyyyMMdd')}"""
        BACKUP_DIR = "/var/lib/jenkins/backups/web_snapshot_${DATE}"
        DB_NAME = "florida_sos"
        DB_USER = "backupuser"
    }
    stages {
        stage('Prepare Snapshot Folder') {
            steps {
                sh "mkdir -p ${BACKUP_DIR}"
            }
        }

        stage('MySQL Dump') {
            steps {
                withCredentials([string(credentialsId: 'mysql-backup-pass', variable: 'DB_PASS')]) {
                    script {
                        def dumpCommand = "mysqldump -u ${DB_USER} -p${DB_PASS} ${DB_NAME} > ${BACKUP_DIR}/${DB_NAME}_${DATE}.sql"
                        def result = sh(script: dumpCommand, returnStatus: true)
                        if (result != 0) {
                            sh "echo ❌ mysqldump failed, aborting backup"
                            error("mysqldump failed")
                        }
                    }
                }
            }
        }

        stage('Rsync Web Directory') {
            steps {
                sh "rsync -a /var/www/ ${BACKUP_DIR}/www"
            }
        }

        stage('Compress Snapshot') {
            steps {
                sh "tar -czf ${BACKUP_DIR}.tar.gz -C /var/lib/jenkins/backups web_snapshot_${DATE}"
            }
        }

        stage('Upload to S3') {
            steps {
                withCredentials([string(credentialsId: 's3-bucket-name', variable: 'BUCKET_NAME')]) {
                    sh "aws s3 cp ${BACKUP_DIR}.tar.gz s3://${BUCKET_NAME}/backups/"
                }
            }
        }

        stage('Update Snapshot Symlink') {
            steps {
                sh "ln -sfn ${BACKUP_DIR} /var/lib/jenkins/backups/web_snapshot_latest"
            }
        }

        stage('Delete Old Backups') {
            steps {
                sh "find /var/lib/jenkins/backups -maxdepth 1 -type d -name 'web_snapshot_*' -mtime +14 -exec rm -rf {} +"
                sh "find /var/lib/jenkins/backups -maxdepth 1 -type f -name 'web_snapshot_*.tar.gz' -mtime +14 -exec rm -f {} +"
            }
        }

        stage('Slack Notification') {
            steps {
                withCredentials([string(credentialsId: 'slack-webhook-url', variable: 'SLACK_WEBHOOK')]) {
                    sh """
                        curl -X POST -H 'Content-type: application/json' \
                        --data '{"text":"✅ Backup completed for ${DATE}."}' \
                        $SLACK_WEBHOOK
                    """
                }
            }
        }
    }
}
