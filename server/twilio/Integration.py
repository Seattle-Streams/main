import json
import os
import boto3
from urllib.parse import unquote

QUEUE_URL = os.environ['SQS_URL']

sqs = boto3.client('sqs')


# Reshape data
def ShapeMessage(message):
    message = message.split("Body=", 1)[1]
    message = message.split("&FromCountry", 1)[0]
    message = unquote(message)
    return message


# ProcessMessage extracts the sms message from the request and sends it to an SQS Queue
def ProcessMessage(event, context):
    message = ShapeMessage(event['body'])

    print("Logging SMS Message: ", message)
    response = sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=message)
    print("Logging SQS Response: ", response)
    return {'statusCode': 200}