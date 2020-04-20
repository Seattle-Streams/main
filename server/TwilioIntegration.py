import json
import boto
import os

# sqs = boto.client('sqs')
queue = boto.sqs.connect(
    'sqs',
    'us-west-2',
)

QUEUE_URL = os.environ['SQS_URL']

# GETting SMS messages from Twilio & sending to MQ


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
    # print(sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=message))
    # print(response)
    return {'statusCode': 200}