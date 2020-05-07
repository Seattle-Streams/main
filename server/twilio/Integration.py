import json
import os
import boto3
from urllib.parse import parse_qs

QUEUE_URL = os.environ['SQS_URL']

sqs = boto3.client('sqs')

# ProcessMessage extracts the sms message from the request and sends it to an SQS Queue
def ProcessMessage(event, context):
    requestJSON = parse_qs(event['body'])
    number = requestJSON['To'][0]
    message = requestJSON['Body'][0]

    response = sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=message, 
    MessageAttributes={'receiving-number': {
        'StringValue': '{number}',
        'DataType': 'String'
    }})
    print("Logging Twilio Receiving Number: ", number)
    print("Logging SMS Message: ", message)
    print("Logging SQS Response: ", response)
    # return {'statusCode': 200}