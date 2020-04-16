import json

# GETting SMS messages from Twilio & sending to MQ

# Reshape data
# def ShapeMessage(message):
#     print(message)
#     return message.body


def ProcessMessage(event, context):
    return {'statusCode': 200, 'body': json.dumps(event)}
    # return {'statusCode': 200, 'body': json.dumps('Hello from Lambda!')}