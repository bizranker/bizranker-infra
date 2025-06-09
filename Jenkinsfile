pipeline {
    agent any

    environment {
        DATE = sh(script: "date +%Y%m%d", returnStdout: true).trim()
        SNAPSHOT_DIR = "/var/lib/jenkins/backups/web_snapshot_${env.DATE}"
        DB_NAME = 'florida_sos'
        DB_BACKUP = "${env.SNAPSHOT_DIR}/${env.DB_NAME}_${env.DATE}.sql"
        FILE_BACKUP = "${env.SNAPSHOT_DIR}.tar.gz"
        WEB_DIR = "/home/naga/web"
        WEB_SNAPSHOT_LAST = "/var/lib/jenkins/backups/web_snapshot_last"
    }

    options {
        timestamps()
    }

    stages {
        stage('Prepare Snapshot Folder') {
            steps {
                sh 'mkdir -p "$SNAPSHOT_DIR"'
            }
        }

        stage('MySQL Dump') {
            steps {
                withCredentials([
                    usernamePassword(credentialsId: 'backupuser-username', usernameVariable: 'DB_USER', passwordVariable: 'DB_PASS')
                ]) {
                    sh '''
                    if ! mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$DB_BACKUP"; then
                        echo ❌ mysqldump failed, aborting backup
                        exit 1
                    fi
                    '''
                }
            }
        }

        stage('Rsync Web Directory') {
            steps {
                sh 'rsync -a --delete --link-dest="$WEB_SNAPSHOT_LAST" "$WEB_DIR/" "$SNAPSHOT_DIR"'
            }
        }

        stage('Compress Snapshot') {
            steps {
                sh 'tar -czf "$FILE_BACKUP" -C "$(dirname "$SNAPSHOT_DIR")" "$(basename "$SNAPSHOT_DIR")"'
            }
        }

        stage('Upload to S3') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                    export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
                    export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
                    aws s3 cp "$FILE_BACKUP" "s3://usreliance-floridasos-backups/"
                    aws s3 cp "$DB_BACKUP" "s3://usreliance-floridasos-backups/"
                    '''
                }
            }
        }

        stage('Update Snapshot Symlink') {
            steps {
                sh '''
                rm -f "$WEB_SNAPSHOT_LAST"
                ln -s "$SNAPSHOT_DIR" "$WEB_SNAPSHOT_LAST"
                '''
            }
        }

        stage('Delete Old Backups') {
            steps {
                sh '''
                find /var/lib/jenkins/backups -name '*.sql' -type f -mtime +30 -delete
                find /var/lib/jenkins/backups -name '*.tar.gz' -type f -mtime +30 -delete
                '''
            }
        }

        stage('Slack Notification') {
            steps {
                withCredentials([string(credentialsId: 'slack-webhook-backup', variable: 'SLACK_WEBHOOK')]) {
                    sh '''
                    curl -X POST -H "Content-type: application/json" \
                    --data '{"text":"✅ Backup completed successfully on '"$(hostname)"' @ '"$(date)"'"}' \
                    "$SLACK_WEBHOOK"
                    '''
                }
            }
        }
    }
}
