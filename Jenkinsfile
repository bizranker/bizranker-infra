
pipeline {
    agent any

    environment {
        DB_USER = credentials('backupuser-username')
        DB_PASS = credentials('backupuser-password')
        BUCKET  = 'usreliance-floridasos-backups'
        DB_NAME = 'florida_sos'
        DATE    = "${new Date().format('yyyyMMdd')}"
        SNAPSHOT_DIR = "/home/naga/web_snapshot_${DATE}"
        DB_BACKUP = "${SNAPSHOT_DIR}/${DB_NAME}_${DATE}.sql"
        FILE_BACKUP = "${SNAPSHOT_DIR}.tar.gz"
        WEB_DIR = "/home/naga/web"
        WEB_SNAPSHOT_LAST = "/home/naga/web_snapshot_last"
        SLACK_WEBHOOK = credentials('slack-webhook-backup')
    }

    options {
        timestamps()
    }

    stages {
        stage('Prepare Snapshot Folder') {
            steps {
                sh 'mkdir -p $SNAPSHOT_DIR'
            }
        }

        stage('MySQL Dump') {
            steps {
                sh '''
                mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$DB_BACKUP"
                '''
            }
        }

        stage('Rsync Web Directory') {
            steps {
                sh '''
                rsync -a --delete --link-dest="$WEB_SNAPSHOT_LAST" "$WEB_DIR/" "$SNAPSHOT_DIR"
                '''
            }
        }

        stage('Compress Snapshot') {
            steps {
                sh '''
                tar -czf "$FILE_BACKUP" -C "$(dirname $SNAPSHOT_DIR)" "$(basename $SNAPSHOT_DIR)"
                '''
            }
        }

        stage('Upload to S3') {
            steps {
                sh '''
                aws s3 cp "$DB_BACKUP" "s3://$BUCKET/"
                aws s3 cp "$FILE_BACKUP" "s3://$BUCKET/"
                '''
            }
        }

        stage('Update Symlink') {
            steps {
                sh '''
                rm -f "$WEB_SNAPSHOT_LAST"
                ln -s "$SNAPSHOT_DIR" "$WEB_SNAPSHOT_LAST"
                '''
            }
        }

        stage('Cleanup Old Files') {
            steps {
                sh '''
                find /home/naga/ -name '*.sql' -type f -mtime +30 -delete
                find /home/naga/ -name '*.tar.gz' -type f -mtime +30 -delete
                '''
            }
        }

        stage('Slack Notification') {
            steps {
                sh '''
                curl -X POST -H "Content-type: application/json" \
                --data "{\"text\":\"✅ FloridaSOS Backup completed successfully on $(hostname) at $(date)\"}" \
                "$SLACK_WEBHOOK"
                '''
            }
        }
    }

    post {
        failure {
            sh '''
            curl -X POST -H "Content-type: application/json" \
            --data "{\"text\":\"❌ FloridaSOS Backup FAILED on $(hostname) at $(date)\"}" \
            "$SLACK_WEBHOOK"
            '''
        }
    }
}
Merge branch 'master' of https://github.com/bizranker/bizranker-infra
