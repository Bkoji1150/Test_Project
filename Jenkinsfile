pipeline {
    agent any
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    environment { 
        AWS_REGION = 'us-east-1'
        ECRREGISTRY = '545135175756.dkr.ecr.us-east-1.amazonaws.com' 
        IMAGENAME = 'haplet-cave'
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
        stage('Unit Tests Execution') {
            steps {
                sh 'mvn surefire:test'
            }
        }
        stage("Static Code analysis With SonarQube") {
            agent any
            steps {
              withSonarQubeEnv('SonarQube') {
                sh "mvn clean package sonar:sonar -Dsonar.host.url=http://54.85.48.113:9000 -Dsonar.login=8912b1866f72ab9c697e44d5befabf76bb4e16d0 -Dsonar.projectKey=jenkins -Dsonar.projectName=haplet-cave -Dsonar.projectVersion=1.0"
                sh "cp /var/lib/jenkins/workspace/Haplet-CI@2/webapp.war /var/lib/jenkins/workspace/Haplet-CI/"  
              }
            }
          } 
        stage('docker build and Tag Application') {
            steps { 
                 sh 'sudo docker build -t ${IMAGENAME} .'
                 sh 'sudo docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
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
        // For non-release candidates, This can be as simple as tagging the artifact(s) with a timestamp and the build number of the job performing the CI/CD process.
         stage('Publish the Artifact to ECR') {
            steps {
                sh 'sudo docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
                sh 'sudo docker rmi ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
            }
        }
    }
}

         

