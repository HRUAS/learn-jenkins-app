pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'd04d85b1-a25f-43ca-a9ff-b21d32a04c64'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
        REACT_APP_VERSION = "1.0.$BUILD_ID"
    }
    stages {

        stage('AWS'){
            agent{
                docker{
                    image 'amazon/aws-cli'
                    arge '--entrypoint=""'
                }
            }
            steps{
                sh '''
                aws --version
                '''
            }
        }

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

        stage('Staging E2E') {
                    agent {
                        docker {
                            image 'my-playright'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'staging_url'
                    }

                    steps {
                        sh '''
                           netlify --version
                           echo "Deploying to staging change netlify site id is : $NETLIFY_SITE_ID"
                           netlify status
                           ls -la
                           netlify deploy --dir=build --json > deploy_output.json
                           CI_ENVIRONMENT_URL=$(node-jq -r '.deploy_url' deploy_output.json)
                           npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false,
                            reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E Report',
                            reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
        }

        // stage('approval') {
        //     steps {
        //         timeout(time: 20, unit: 'SECONDS') {
        //             input message: 'Ready to deploy', ok: 'Yes, I am sure to deploy'
        //         }
        //     }
        // }

        stage('PROD Deploy') {
                    agent {
                        docker {
                            image 'my-playright'
                            reuseNode true
                        }
                    }

                    environment {
                        CI_ENVIRONMENT_URL = 'https://akhil433.netlify.app'
                    }

                    steps {
                        sh '''
                           netlify --version
                           echo "deploy on prod change netlify site id is : $NETLIFY_SITE_ID"
                           netlify status
                           ls -la
                           netlify deploy --dir=build --prod
                           sleep 5
                           npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false,
                            reportDir: 'playwright-report', reportFiles: 'index.html',
                            reportName: 'PROD E2E Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
        }
    }
}
