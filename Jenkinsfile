pipeline {
    agent any
    tools {
      dockerTool 'docker'
      jdk 'JAVA_HOME'
      maven 'M2_HOME'
      git 'Default'
    }
    stages {
        stage('Git Clone') {
            steps {
                git 'https://github.com/DVSR1411/todo-app.git'
            }
        }
        stage('Maven build') {
            steps {
                sh 'mvn clean install package'
            }
        }
        stage('Docker build') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'passwd', usernameVariable: 'uname')]) {
                    sh 'docker login -u $uname -p $passwd'
                    sh 'docker build -t $uname/todo-app:v1 .'
                }
            }
        }
        stage('Docker push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'passwd', usernameVariable: 'uname')]) {
                    sh 'docker push $uname/todo-app:v1'
                }
            }
        }
        stage('Kubernetes deploy') {
            steps {
                sh 'kubectl apply -f manifests/.'
            }
        }
    }
}
