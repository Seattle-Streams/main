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
    message = message.replace("+", " ")
    message = unquote(message)
    return message

def GetNumber(message):
    number = message.split("To=", 1)[1]
    number = number[:40]
    number = unquote(number)
    return number

# ProcessMessage extracts the sms message from the request and sends it to an SQS Queue
def ProcessMessage(event, context):
    number = GetNumber(event['body'])
    print("Logging Twilio Receiving number: ", number)
    message = ShapeMessage(event['body'])

    print("Logging SMS Message: ", message)
    response = sqs.send_message(QueueUrl=QUEUE_URL, MessageBody=message, 
    MessageAttributes={'receiving-number': {
        'StringValue': '{number}',
        'DataType': 'String'
    }})
    print("Logging SQS Response: ", response)
    # return {'statusCode': 200}