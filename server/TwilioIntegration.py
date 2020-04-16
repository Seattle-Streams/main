import requests

# GETting SMS messages from Twilio & sending to MQ


# Reshape data
def ShapeMessage(message):
    print(message)
    return message.body


def ProcessMessage(event, context):
    print(event)
    final_message = ShapeMessage(event.message)
    print(final_message)
    return {'statusCode': 200, 'body': json.dumps('Hello from Lambda!')}