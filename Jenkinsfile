def bucket = 'lamdba_builds'
def functionName = 'twilio_lambda'
def region = 'us-west-2'

pipeline {
    agent any
    stages {
        stage('Checkout'){
            checkout scm
        }

        stage('Test'){
            sh 'cd ./TwilioIntegration'
            sh 'mkdir ./dependencies'
            sh 'sudo python -m ensurepip --default-pip'
            sh 'pip install boto3 -t ./dependencies'
        }

        stage('Build'){
            sh 'cd ./TwilioIntegration'
            sh './build'
            sh "zip ${commitID()}.zip main"
        }

        stage('Push'){
            sh 'cd ./TwilioIntegration'
            sh "aws s3 cp ${commitID()}.zip s3://${bucket}"
        }

        stage('Deploy'){
            sh 'cd ./TwilioIntegration'
            sh "aws lambda update-function-code --function-name ${functionName} \
                    --s3-bucket ${bucket} \
                    --s3-key ${commitID()}.zip \
                    --region ${region}"
        }
    }
}

def commitID() {
    sh 'git rev-parse HEAD > .git/commitID'
    def commitID = readFile('.git/commitID').trim()
    sh 'rm .git/commitID'
    commitID
}