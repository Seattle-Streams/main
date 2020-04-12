import requests
import pika

# GETting SMS messages from Twilio & sending to MQ
class TwilioIntegration:
    def __init__(self, authToken):
        self.authToken = authToken

    # Authenticate w/ Twilio & store token in Token Store (S3)
    def TwilioAuth():
        
    # Gets Twilio auth token from Token Store (S3) to send requests
    def GetStoredToken():

    # GET request to Twillio for messages
    def GETTwilioMessages():
        # IF token is expired,
        if ():
            # re-authenticate with Twilio
            # Store auth token in Token Store (S3)

        badStatus = True
        URL = "URL for Twilio"
        PARAMS = {'param_key':param_value} 
    
        while badStatus:
            # sending GET request for Twilio messages
            response = requests.GET(url = URL, params = PARAMS) 
            data = response.json()
            # TODO: Check that this is the proper way to check response status
            if (data["status"] < 400 & data["status"] > 199):
                badStatus = False

    # Reshape data
    def ShapeMessages():

    # Send messages to MQ
    def ProduceMessages(channel, messages):
        for message in messages:
            channel.basic_publish(exchange='', routing_key='youtube-messages', body='{message}')

    def ProcessMessages():
        # Connect to MQ
        connection = pika.BlockingConnection(pika.ConnectionParameters(host='localhost'))
        channel = connection.channel()
        channel.queue_declare(queue='youtube-messages')
        
        messages = GETTwilioMessages()
        final_messages = ShapeMessages(messages)
        ProduceMessages(channel, final_messages)
