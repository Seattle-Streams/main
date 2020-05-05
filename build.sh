rm -f lambdaChanges
git diff --name-only HEAD 309375ea5794ce86ae2e087aeb2ed5d6304e7942 | grep -i 'Integration\|build' > lambdaChanges

if [ -s "$lambdaChanges" ];
then
    echo "No changes... skipping build"
    exit
fi

build_twilio=0
build_youtube=0
while read -r line;
do
    if [ "${line#*/}" == 'twilio/Integration.py' ];
    then
        build_twilio=1
    fi
    if [ "${line##*/}" == 'YoutubeIntegration.py' ] || [ "${line#*/}" == 'youtube/build.sh' ];
    then
        build_youtube=1
    fi
done < lambdaChanges

if [ $build_twilio -eq 1 ];
then
  package twilio
  deploy twilio_function twilio/
fi

if [ $build_youtube -eq 1 ];
then
  package youtube youtube_lambda YoutubeIntegration
  deploy youtube_lambda youtube/
fi

# Installs necessary dependencies and zips them with integration code
function package () {
    cd server/$1
    rm -rf packages
    rm Integration.zip
    mkdir -p packages

    pip3 install -r requirements.txt -t ./packages

    cd packages
    zip -r9 "./../Integration.zip" .
    cd -
    zip -g Integration.zip Integration.py
}
    
# Uploads lambda zip to S3 and updates lambda function code
function deploy () {
    echo "-------------------------------------"
    echo "   Uploading lambda function to S3"
    echo "-------------------------------------"

    aws s3 cp $1.zip s3://process-messages-builds/$2

    aws lambda update-function-code --function-name $1 \
    --s3-bucket process-messages-builds \
    --s3-key $2/$1.zip \
    --region us-west-2

    echo "---------------------"
    echo "   Upload Complete"
    echo "---------------------"
    cd ../..
}