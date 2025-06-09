pipeline {
    agent any

    environment {
        DATE = """${new Date().format('yyyyMMdd')}"""
        SNAPSHOT_DIR = "/var/lib/jenkins/backups/web_snapshot_${env.DATE}"
        SNAPSHOT_NAME = "florida_sos_${env.DATE}.sql"
        COMPRESSED_NAME = "snapshot_${env.DATE}.tar.gz"
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
            steps {
                withCredentials([string(credentialsId: 'mysql-backup-pass', variable: 'DB_PASS')]) {
                    sh '''
                        mysqldump -u backupuser -p${DB_PASS} florida_sos > ${SNAPSHOT_DIR}/${SNAPSHOT_NAME} || {
                            echo "❌ mysqldump failed, aborting backup"
                            exit 1
                        }
                    '''
                }
            }
        }

        stage('Rsync Web Directory') {
            steps {
                sh "rsync -av /var/www/sos/web/ ${SNAPSHOT_DIR}/web"
            }
        }

        stage('Compress Snapshot') {
            steps {
                sh "tar -czf ${SNAPSHOT_DIR}/${COMPRESSED_NAME} -C ${SNAPSHOT_DIR} ."
            }
        }

        stage('Upload to S3') {
            steps {
                withCredentials([string(credentialsId: 'aws-cli-profile', variable: 'AWS_PROFILE')]) {
                    sh "aws s3 cp ${SNAPSHOT_DIR}/${COMPRESSED_NAME} s3://usreliance-backups/ --profile ${AWS_PROFILE}"
                }
            }
        }

        stage('Update Snapshot Symlink') {
            steps {
                sh "ln -sfn ${SNAPSHOT_DIR} /var/lib/jenkins/backups/latest"
            }
        }

        stage('Delete Old Backups') {
            steps {
                sh "find /var/lib/jenkins/backups -maxdepth 1 -type d -mtime +7 -exec rm -rf {} +"
            }
        }

        stage('Slack Notification') {
            steps {
                withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
                    sh '''
                        curl -X POST -H 'Content-type: application/json' --data "{
                            \\"text\\": \\"✅ Backup completed for ${DATE}\\"
                        }" $SLACK_WEBHOOK
                    '''
                }
            }
        }
    }
}
