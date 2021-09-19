pipeline {
    agent any
    tools {
        maven 'M2_HOME'
        jdk 'JAVA_HOME'
    }
    environment { 
        AWS_REGION = 'us-east-1'
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
    }   
}
