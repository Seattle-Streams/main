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
    # The context of the text message from Twilio
    # print(event['body'])
    message = ShapeMessage(event['body'])

    print("SMS Message: ", message)
    # TODO: Attach permissions to this lambda so it can send messages to SQS
    print(sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=message))
    # print(response)
    return {'statusCode': 200}