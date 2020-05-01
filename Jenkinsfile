def bucket = 'process-messages-builds'
def functionName = 'twilio_lambda'
def region = 'us-west-2'

pipeline {
    agent any
    stages {
        stage('Checkout'){
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('Test'){
            steps {
                dir("server/twilio") {
                    sh 'mkdir ./dependencies'
                    sh 'pip install boto3 -t ./dependencies'
                }
            }
        }

        stage('Build'){
            steps {
                dir("server/twilio") {
                    dir("dependencies") {
                        sh 'zip -r9 "./../twilio_lambda.zip" .'
                    }
                    sh "zip -g ${functionName}.zip Integration.py"
                }
            }    
        }

        stage('Push'){
            steps {
                dir("server/twilio") {
                    sh "aws s3 cp ${functionName}.zip s3://${bucket}"
                }
            }
        }

        stage('Deploy'){
            steps {
                dir("server/twilio") {
                    sh "aws lambda update-function-code --function-name ${functionName} \
                            --s3-bucket ${bucket} \
                            --s3-key ${functionName}.zip \
                            --region ${region}"
                }
            }
        }
    }
}