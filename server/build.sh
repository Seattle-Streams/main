#!/usr/bin/env bash

rm twilio_lambda.zip

cd dependencies
zip -r9 "./../twilio_lambda.zip" .
cd -
zip -g twilio_lambda.zip TwilioIntegration.py
