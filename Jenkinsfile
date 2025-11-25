pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "dockerhub_username/devops-home-task"
        APP_SERVER_IP = "X.X.X.X"        // לשים app_public_ip
        SSH_CRED_ID   = "app-ec2-ssh"    // id של credentials ב-Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/USER/REPO.git'
            }
        }

        stage('Lint') {
            steps {
                dir('app') {
                    sh 'pip install flake8'
                    sh 'flake8 .'
                }
            }
        }

        stage('Test') {
            steps {
                dir('app') {
                    sh 'pip install -r requirements.txt'
                    sh 'pytest'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                sshagent (credentials: [SSH_CRED_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ubuntu@${APP_SERVER_IP} '
                      docker login -u $DOCKER_USER -p $DOCKER_PASS
                      docker pull ${DOCKER_IMAGE}:${BUILD_NUMBER} || exit 1
                      docker rm -f app || true
                      docker run -d --name app -p 80:5000 ${DOCKER_IMAGE}:${BUILD_NUMBER}
                    '
                    """
                }
            }
        }

        stage('Health Check') {
            steps {
                sh "curl -f http://${APP_SERVER_IP}/ || (echo 'Healthcheck failed' && exit 1)"
            }
        }
    }
}

