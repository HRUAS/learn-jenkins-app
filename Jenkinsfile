pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = 'd04d85b1-a25f-43ca-a9ff-b21d32a04c64'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }
    stages {
        
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                   ls -la
                   node --version
                   npm --version
                   npm ci
                   npm run build
                   ls -la
                '''
            }
        }

        stage('run Tests') {
            parallel {
                stage('Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                echo 'Test Stage'
                test -f build/index.html
                npm test
                '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                npm install serve
                node_modules/.bin/serve -s build &
                sleep 10
                npx playwright test --reporter=html
                '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'PlayWrite HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                   npm install netlify-cli
                   node_modules/.bin/netlify --version
                   echo "change netlify site id is : $NETLIFY_SITE_ID"
                   node_modules/.bin/netlify status
                   ls -la
                   node_modules/.bin/netlify deploy --dir=build --prod
                '''
            }
        }
    }
}
