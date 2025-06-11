pipeline {
    agent {
        label 'master'
    }

    options {
        shell '/bin/bash'  // 🔥 This forces Jenkins to use bash instead of sh
    }

    environment {
        ENV_PATH = '/home/jenkins/repos/bizranker-infra/.env'
    }

    stages {
        stage('Run Backup Script') {
            steps {
                sh '''
                    echo "🔄 Loading environment from $ENV_PATH"
                    if [ ! -f "$ENV_PATH" ]; then
                      echo "❌ .env file not found at $ENV_PATH"
                      exit 1
                    fi

                    set -a
                    source "$ENV_PATH"
                    set +a

                    echo "✅ Environment loaded for $DB_NAME"
                    bash /home/jenkins/repos/bizranker-infra/backup/backup_to_s3.sh
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
