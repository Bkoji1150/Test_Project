pipeline {
    agent any
    tools {
        maven 'mvn'
        jdk   'JAVA_HOME'
    }
    environment { 
        AWS_REGION = 'us-east-2'
        ECRREGISTRY = '735972722491.dkr.ecr.us-west-2.amazonaws.com' 
        sonarScanResults = null
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
              withSonarQubeEnv(installationName: 'sonar') {
                sh  'mvn sonar:sonar'
              }
            }
          }
          stage ("Waiting for Quality Gate Result") {
              steps {
                  timeout(time: 3, unit: 'MINUTES') {
                  waitForQualityGate abortPipeline: true 
              }
              }
          }


        // stage('docker build and Tag Application') {
        //     steps {
        //          sh 'cp ./webapp/target/webapp.war .'
        //          sh 'docker build -t ${IMAGENAME} .'
        //          sh 'docker tag ${IMAGENAME}:${IMAGE_TAG} ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
        //     }
        // }
        // stage('Deployment Approval') {
        //     steps {
        //       script {
        //         timeout(time: 20, unit: 'MINUTES') {
        //          input(id: 'Deploy Gate', message: 'Deploy Application to Dev ?', ok: 'Deploy')
        //          }
        //        }
        //     }
        // } 
    //     stage('Login To ECR') {
    //         steps {
    //             sh '/usr/local/bin/aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECRREGISTRY}'
    //         }
    //     }
    //      stage('Publish the Artifact to ECR') {
    //         steps {
    //             sh 'docker push ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
    //             sh 'docker rmi ${ECRREGISTRY}/${IMAGENAME}:${IMAGE_TAG}'
    //         }
    //     } 
    //     stage('update ecs service') {
    //         steps {
    //             sh '/usr/local/bin/aws ecs update-service --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --force-new-deployment --region ${AWS_REGION}'
    //         }
    //     }  
    //    stage('wait ecs service stable') {
    //         steps {
    //             sh '/usr/local/bin/aws ecs wait services-stable --cluster ${ECS_CLUSTER} --service ${ECS_SERVICE} --region ${AWS_REGION}'
    //         }
    //     }
    }
        post {
            success {
                script {
                    buildStatusMessage = """
                        New image built and tagged.
                        Version: ${VERSION}
                    """.stripIndent()
                    if (sonarScanResults != null) {
                        buildStatusMessage += "SonarQube Report: ${sonarScanResults}"
                    }

                    String cdJobName = "${CELL_FULL_NAME}-cd/${URLEncoder.encode(params.CD_BRANCH, 'UTF-8')}"
                    Boolean cdJobExists = jenkins.model.Jenkins.instance.getItemByFullName(cdJobName) != null
                    if (params.DEPLOY_ENVIRONMENT !=  '') {
                        if (cdJobExists) {
                            build job: cdJobName,
                            parameters:
                            [
                                string(name: 'PROPERTY_FILE_PATH', value: "${params.PROPERTY_FILE_PATH}"),
                                string(name: 'ENVIRONMENT', value: "${params.DEPLOY_ENVIRONMENT}"),
                                booleanParam(name: 'DEPLOY_LATEST', value: true),
                                string(name:'TESTS_BRANCH', value: "${params.TESTS_BRANCH}"),
                                booleanParam(name:'AUTO_APPROVE', value: true)
                            ]
                        } else {
                            echo "CD Job '${cdJobName}' does not exist. Skipping trigger..."
                        }
                    }
                }
            }
            failure {
                script {
                    if (sonarScanResults != null) {
                         slackSend channel: '#general', color: 'Good', message: "SonarQube Report: ${sonarScanResults}"
                        buildStatusMessage = "SonarQube Report: ${sonarScanResults}"
                    }
                }
            }
            cleanup {
                script {
                    try {
                        workspace.tearDown(
                            CELL_FULL_NAME,
                            PROPERTIES.removeImage == null ? false : PROPERTIES.removeImage as Boolean
                        )
                    } catch (Exception e) {
                        echo 'An exception occurred while tearing down the workspace:'
                        echo e.getMessage()
                    }
                    // try {
                    //     metrics.publishCloudwatchBuildMetrics()
                    // } catch (Exception e) {
                    //     echo 'An exception occurred while publishing Cloudwatch Metrics:'
                    //     echo e.getMessage()
                    // }(

                    // slackSend channel: '#general', color: 'Good', message: "SonarQube Report: ${sonarScanResults}"
                }
            }
        }
}
