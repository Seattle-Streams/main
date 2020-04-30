#!/usr/bin/env bash

mkdir dependencies
pip install boto3 -t ./dependencies
cd dependencies
zip -r9 "./../twilio_lambda.zip" .
cd -
zip -g twilio_lambda.zip TwilioIntegration.py

echo "-------------------------------------"
echo "   Uploading lambda function to S3"
echo "-------------------------------------"

aws s3 cp twilio_lambda.zip s3://process-messages-builds

aws lambda update-function-code --function-name twilio_lambda \
--s3-bucket process-messages-builds \
--s3-key twilio_lambda.zip \
--region us-west-2

echo "---------------------"
echo "   Upload Complete"
echo "---------------------"

rm -rf dependencies
rm twilio_lambda.zip