import json
import os
import boto3

QUEUE_URL = os.environ['SQS_URL']

sqs = boto3.client('sqs')


# Reshape data
def ShapeMessage(message):
    message = message.split("Body=", 1)[1]
    message = message.split("&FromCountry", 1)[0]
    message = message.replace("+", " ")
    return message


def ProcessMessage(event, context):
    message = ShapeMessage(event['body'])

    print("Logging SMS Message: ", message)
    response = sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=message)
    print("Logging SQS Response: ", response)
    return {'statusCode': 200}