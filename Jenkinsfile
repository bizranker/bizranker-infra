pipeline {
    agent {
        label 'master'
    }

    environment {
        ENV_PATH = '/var/lib/jenkins/bizranker-infra/.env'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '🔁 Pulling latest code from GitHub...'
                checkout scm
            }
        }

        stage('Run Backup Script') {
            steps {
                sh '''
                    echo "🔄 Loading environment from $ENV_PATH"

                    if [ ! -f "$ENV_PATH" ]; then
                        echo "❌ .env file not found at $ENV_PATH"
                        exit 1
                    fi

                    set -a
                    . "$ENV_PATH"
                    set +a

                    echo "✅ Environment loaded for $DB_NAME"
                    bash backup/backup_to_s3.sh
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Backup completed successfully!'
        }
        failure {
            echo '❌ Backup job failed. Please check Jenkins logs and Slack.'
        }
    }
}
