pipeline {
    agent any

    environment {
        ENV_FILE = "${WORKSPACE}/.env"
    }

    stages {
        stage('Load Environment') {
            steps {
                script {
                    def envFile = readFile("${ENV_FILE}").split("\n")
                    envFile.each {
                        if (it.trim() && !it.startsWith("#")) {
                            def (key, value) = it.tokenize("=")
                            env[key.trim()] = value.replaceAll('^"|"$', '')
                        }
                    }
                }
            }
        }

        stage('Run Backup Script') {
            steps {
                sh 'bash backup/backup_to_s3.sh'
            }
        }
    }

    post {
        failure {
            echo "Backup job failed. Please check logs or Slack for errors."
        }
        success {
            echo "Backup job completed successfully!"
        }
    }
}
