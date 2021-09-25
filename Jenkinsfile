pipeline {
    agent any
    tools {
        maven 'maven3.8'
        jdk 'jdk'
    }
    environment { 
        AWS_REGION = 'us-west-2'
        ECRREGISTRY = '735972722491.dkr.ecr.us-west-2.amazonaws.com' 
        IMAGENAME = 'haplet-registory' 
        IMAGE_TAG = 'latest'
        ECS_CLUSTER = 'myapp-cluster'
        ECS_SERVICE = 'myapp-service'
    }
    stages {
       stage ('Cloning git & Build') {
          steps {
                checkout scm
            }
        }
         stage('Compile') {
            steps {
                sh 'mvn clean package -DskipTests=true'
            }
        }
         stage('Unit Tests Execution') {
            steps {
                sh 'mvn surefire:test'
            }
        }
         stage("Static Code analysis With SonarQube") {
            agent any                                               
            steps {
              withSonarQubeEnv('sonnar-scanner') {
                sh "mvn clean package sonar:sonar -Dsonar.host.url=http://54.213.169.168:9000 -Dsonar.login=cc92b9fece4552a752667e25ff8a1064f7447e3d -Dsonar.projectKey=jenkins -Dsonar.projectName=haplet -Dsonar.projectVersion=1.0"
              }
            }
          }
        stage('docker build and Tag Application') {
            steps {
                 sh 'cp ./webapp/target/webapp.war .'
                 sh 'docker build -t ${IMAGENAME} .'
                 sh 'docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }
        stage('Deployment Approval') {
            steps {
              script {
                timeout(time: 20, unit: 'MINUTES') {
                 input(id: 'Deploy Gate', message: 'Deploy Application to Dev ?', ok: 'Deploy')
                 }
               }
            }
        } 
        stage('Login To ECR') {
            steps {
                sh '/usr/local/bin/aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECRREGISTRY}' 
            }
        }
         stage('Publish the Artifact to ECR') {
            steps {
                sh 'docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
                sh 'docker rmi ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        } 
        stage('update ecs service') {
            steps {
                sh '/usr/local/bin/aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --region ${AWS_REGION} -force-new-deployment true'
            }
        }  
       stage('wait ecs service stable') {
            steps {
                sh 'docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }
        post {
            always {
               junit 'target/surefire-reports/TEST-*.xml'
                deleteDir()
            }
    }
}
