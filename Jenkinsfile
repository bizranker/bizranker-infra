pipeline {
    agent {
        label 'master'
    }

    environment {
        ENV_PATH = '/home/jenkins/repos/bizranker-infra/.env'
    }

    stages {
        stage('Run Backup Script') {
            steps {
                sh "bash -c '\n\
                    echo 🔄 Loading environment from \$ENV_PATH && \n\
                    if [ ! -f \"\$ENV_PATH\" ]; then \n\
                      echo \"❌ .env file not found at \$ENV_PATH\" && exit 1 \n\
                    fi && \n\
                    set -a && \n\
                    source \"\$ENV_PATH\" && \n\
                    set +a && \n\
                    echo \"✅ Environment loaded for \$DB_NAME\" && \n\
                    bash /home/jenkins/repos/bizranker-infra/backup/backup_to_s3.sh \n\
                '"
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
