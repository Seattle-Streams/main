#!/usr/bin/env bash

mkdir -p dependencies

pip3 install boto3 -t ./dependencies
pip3 install httplib2 -t ./dependencies
pip3 install google-api-python-client -t ./dependencies
pip3 install oauth2client -t ./dependencies

cd dependencies
zip -r9 "./../$1.zip" .
cd -
zip -g $1.zip $2.py

echo "-------------------------------------"
echo "   Uploading lambda function to S3"
echo "-------------------------------------"

aws s3 cp $1.zip s3://process-messages-builds

aws lambda update-function-code --function-name $1 \
--s3-bucket process-messages-builds \
--s3-key $1.zip \
--region us-west-2

echo "---------------------"
echo "   Upload Complete"
echo "---------------------"

rm -rf dependencies
rm $1.zip