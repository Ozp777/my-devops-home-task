pipeline {
    agent any

    parameters {
        string(
            name: 'DOCKER_IMAGE',
            defaultValue: 'ozpos/devops-home-task',
            description: 'Docker Hub repository (e.g. user/devops-home-task)'
        )
        string(
            name: 'APP_SERVER_IP',
            defaultValue: '3.81.165.198',
            description: 'Public IP of the App EC2 instance'
        )
    }

    environment {
        DOCKER_CREDENTIALS_ID = 'dockerhub-creds'
        SSH_CREDENTIALS_ID    = 'app-ec2-ssh'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Using source from SCM"
                sh 'pwd && ls -R'
            }
        }

        stage('Lint') {
            steps {
                echo 'מריץ flake8 על קוד האפליקציה...'
                dir('app') {
                    sh 'python3 -m pip install --user flake8'
                    sh '~/.local/bin/flake8 . || flake8 .'
                }
            }
        }

        stage('Unit Tests') {
            steps {
                echo 'מריץ pytest...' 
                dir('app') {
                    sh 'python3 -m pip install --user -r requirements.txt'
                    sh '~/.local/bin/pytest || pytest'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "${params.DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                    echo "בונה Docker image: ${imageTag}"
                    dir('app') {
                        sh "docker build -t ${imageTag} ."
                    }
                    env.IMAGE_TAG = imageTag
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo "דוחף את ה-image ל-Docker Hub: ${env.IMAGE_TAG}"
                    withCredentials([usernamePassword(
                        credentialsId: env.DOCKER_CREDENTIALS_ID,
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh "echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin"
                        sh "docker push ${env.IMAGE_TAG}"
                    }
                }
            }
        }

        stage('Deploy to App EC2') {
            steps {
                script {
                    echo "מבצע deploy לשרת האפליקציה ${params.APP_SERVER_IP} עם image ${env.IMAGE_TAG}"

                    sshagent (credentials: [env.SSH_CREDENTIALS_ID]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ubuntu@${params.APP_SERVER_IP} '
                          docker pull ${env.IMAGE_TAG} &&
                          docker rm -f app || true &&
                          docker run -d --name app -p 80:5000 ${env.IMAGE_TAG}
                        '
                        """
                    }
                }
            }
        }

        stage('Health Check') {
            steps {
                echo "מריץ Health Check על http://${params.APP_SERVER_IP}/ ..."
                sh "curl -f http://${params.APP_SERVER_IP}/ || (echo 'Healthcheck failed' && exit 1)"
            }
        }
    }

    post {
        success {
            echo 'ה-Pipeline הסתיים בהצלחה ✅'
        }
        failure {
            echo 'ה-Pipeline נכשל ❌ – יש לבדוק את ה-log בשלבים'
        }
    }
}

