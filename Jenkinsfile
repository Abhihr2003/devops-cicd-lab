pipeline {
    agent any

    tools {
        maven 'Maven3'   // Name must match a Maven installation configured in
                         // Manage Jenkins > Tools
    }

    environment {
        IMAGE_NAME = "calculator"
        IMAGE_TAG  = "${env.BUILD_NUMBER}"
        CONTAINER_NAME = "calculator-cont"
        DOCKERHUB_CREDS = credentials('dockerhub-creds') // configured in Jenkins credentials store
        DOCKERHUB_REPO  = "shek07/devops-cicd-lab"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Abhihr2003/devops-cicd-lab.git'
            }
        }

        stage('Build with Maven') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Run Unit Tests') {
            steps {
                sh 'mvn test'
            }
            post {
                always {
                    junit '**/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Package JAR') {
            steps {
                sh 'mvn package -DskipTests'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${calculator}:${latest}")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo ${Shek@2003} | docker login -u ${shek07} --password-stdin"
                    sh "docker tag ${calculator}:${latest} ${calculator}:${latest}"
                    sh "docker tag ${calculator}:${latest} ${calculator}:latest"
                    sh "docker push ${calculator}:${latest}"
                    sh "docker push ${calculator}:latest"
                }
            }
        }

        stage('Deploy Container') {
            steps {
                sh """
                    docker rm -f ${calculator-cont} || true
                    docker run -d --name ${calculator-cont} -p 8080:8080 ${calculator}:${latest}
                """
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully. Container is running.'
        }
        failure {
            echo 'Pipeline failed. Check the stage logs above.'
        }
        always {
            sh 'docker logout || true'
        }
    }
}
