pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'd04d85b1-a25f-43ca-a9ff-b21d32a04c64'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        AWS_S3_BUCKET = 's3://akhil433-bucket-20250709'
        AWS_DEFAULT_REGION = 'us-east-1'
        REACT_APP_VERSION = "1.0.$BUILD_ID"
        APP_NAME = 'leanjenkinsapp'
        AWS_ECS_CLUSTER = 'gifted-shark-8tbu9g'
        AWS_ECS_SERVICE = 'LearnJenkinsApp-TaskDefinition-Prod-service-m4wa1cnq'
        AWS_ECS_TASK_DEFINITION = 'LearnJenkinsApp-TaskDefinition-Prod'
        AWS_DOCKER_REGISTORY = '956544096573.dkr.ecr.us-east-1.amazonaws.com'
    }
    stages {
        // stage('docker') {
        //     steps {
        //         sh 'docker build -t my-playright .'
        //     }
        // }

        // stage('Build') {
        //     agent {
        //         docker {
        //             image 'node:18-alpine'
        //             reuseNode true
        //         }
        //     }
        //     steps {
        //         sh '''
        //            ls -la
        //            node --version
        //            npm --version
        //            npm ci
        //            npm run build
        //            ls -la
        //         '''
        //     }
        // }

        stage('Build Docker Image') {
            agent {
                docker {
                    image 'my-aws-cli'
                    reuseNode true
                    args '-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=""'
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                docker build -t $AWS_DOCKER_REGISTORY/$APP_NAME:$REACT_APP_VERSION .
                aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_DOCKER_REGISTORY
                docker push $AWS_DOCKER_REGISTORY/$APP_NAME:$REACT_APP_VERSION
                '''
                }
            }
        }

        stage('AWS') {
            agent {
                docker {
                    image 'my-aws-cli'
                    args '--entrypoint=""'
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                aws --version
                sed -i "s/#APP_VERSION#/$REACT_APP_VERSION/g" aws/task-definition.json
                LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition.json | jq '.taskDefinition.revision')
                echo "LATEST_TD_REVISION: $LATEST_TD_REVISION"
                aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE --task-definition $AWS_ECS_TASK_DEFINITION:$LATEST_TD_REVISION
                aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE
                '''
                }
            }
        }

        // aws s3 sync build $AWS_S3_BUCKET
        // aws s3 ls $AWS_S3_BUCKET

        // stage('run Tests') {
        //     parallel {
        //         stage('Test') {
        //             agent {
        //                 docker {
        //                     image 'node:18-alpine'
        //                     reuseNode true
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                    echo 'Test Stage'
        //                    test -f build/index.html
        //                    npm test
        //                 '''
        //             }
        //             post {
        //                 always {
        //                     junit 'jest-results/junit.xml'
        //                 }
        //             }
        //         }

        //         stage('E2E') {
        //             agent {
        //                 docker {
        //                     image 'my-playright'
        //                     reuseNode true
        //                 }
        //             }
        //             steps {
        //                 sh '''
        //                    serve -s build &
        //                    sleep 5
        //                    npx playwright test --reporter=html
        //                 '''
        //             }
        //             post {
        //                 always {
        //                     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'PlayWrite Local Report', reportTitles: '', useWrapperFileDirectly: true])
        //                 }
        //             }
        //         }
        //     }
        // }

        // stage('Staging E2E') {
        //             agent {
        //                 docker {
        //                     image 'my-playright'
        //                     reuseNode true
        //                 }
        //             }

        //             environment {
        //                 CI_ENVIRONMENT_URL = 'staging_url'
        //             }

        //             steps {
        //                 sh '''
        //                    netlify --version
        //                    echo "Deploying to staging change netlify site id is : $NETLIFY_SITE_ID"
        //                    netlify status
        //                    ls -la
        //                    netlify deploy --dir=build --json > deploy_output.json
        //                    CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy_output.json)
        //                    npx playwright test --reporter=html
        //                 '''
        //             }
        //             post {
        //                 always {
        //                     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false,
        //                     reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E Report',
        //                     reportTitles: '', useWrapperFileDirectly: true])
        //                 }
        //             }
        // }

        // stage('approval') {
        //     steps {
        //         timeout(time: 20, unit: 'SECONDS') {
        //             input message: 'Ready to deploy', ok: 'Yes, I am sure to deploy'
        //         }
        //     }
        // }

        // stage('PROD Deploy') {
        //             agent {
        //                 docker {
        //                     image 'my-playright'
        //                     reuseNode true
        //                 }
        //             }

        //             environment {
        //                 CI_ENVIRONMENT_URL = 'https://akhil433.netlify.app'
        //             }

    //             steps {
    //                 sh '''
    //                    netlify --version
    //                    echo "deploy on prod change netlify site id is : $NETLIFY_SITE_ID"
    //                    netlify status
    //                    ls -la
    //                    netlify deploy --dir=build --prod
    //                    sleep 5
    //                    npx playwright test --reporter=html
    //                 '''
    //             }
    //             post {
    //                 always {
    //                     publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false,
    //                     reportDir: 'playwright-report', reportFiles: 'index.html',
    //                     reportName: 'PROD E2E Report', reportTitles: '', useWrapperFileDirectly: true])
    //                 }
    //             }
    // }
    }
}
