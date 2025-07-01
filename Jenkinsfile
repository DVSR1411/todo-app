pipeline {
    agent any
    tools {
      git 'Default'
      jdk 'Java'
      maven 'Maven'
      dockerTool 'Docker'
    }
    stages {
        stage('Git checkout') {
            steps {
                git 'https://github.com/DVSR1411/todo-app.git'
            }
        }
        stage('Maven build') {
            steps {
                sh 'mvn clean install package'
            }
        }
        stage('Docker build and push') {
            steps {
                sh '''
                aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $DOCKER_URL
                docker build -t $DOCKER_REPO .
                docker tag $DOCKER_REPO:$DOCKER_TAG $DOCKER_URL/$DOCKER_REPO:$DOCKER_TAG
                docker push $DOCKER_URL/$DOCKER_REPO:$DOCKER_TAG
                '''
            }
        }
        stage('Kubernetes deploy') {
            steps {
                sh '''
                sed -i "s#dvsr1411/todo-app:v1#$DOCKER_URL/$DOCKER_REPO:$DOCKER_TAG#g" manifests/tomcat.yml
                CREDENTIALS=$(aws sts assume-role --role-arn $KUBECTL_ROLE --role-session-name ec2-kubectl --duration-seconds 900)
                export AWS_ACCESS_KEY_ID="$(echo ${CREDENTIALS} | jq -r '.Credentials.AccessKeyId')"
                export AWS_SECRET_ACCESS_KEY="$(echo ${CREDENTIALS} | jq -r '.Credentials.SecretAccessKey')"
                export AWS_SESSION_TOKEN="$(echo ${CREDENTIALS} | jq -r '.Credentials.SessionToken')"
                export AWS_EXPIRATION=$(echo ${CREDENTIALS} | jq -r '.Credentials.Expiration')
                aws eks update-kubeconfig --name $EKS_CLUSTER --region $REGION
                kubectl apply -f manifests/.
                '''
            }
        }
    }
}
