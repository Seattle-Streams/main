import requests

# GETting SMS messages from Twilio & sending to MQ
class TwilioIntegration:
    def __init__(self, authToken):
        self.authToken = authToken

    # Authenticate w/ Twilio & store token in S3
    def TwilioAuth():
        
        # Gets Twilio auth token from Token Store (S3 in our case) to send requests
    def GetStoredToken():

    # GET request to Twillio for messages
    def GETTwilioMessages():
        URL = "URL for Twilio"
        PARAMS = {'param_key':param_value} 
        
        # sending get request and saving the response as response object 
        response = requests.POST(url = URL, params = PARAMS) 
        # extracting data in json format 
        data = response.json()

    # Reshape data
    def ShapeMessages():

    # Send messages to MQ
    def ProduceMessages():
        # Connect to MQ

    def ProcessMessages():
        # Connect to MQ
        
        GETTwilioMessages()
        ShapeMessages()
        ProduceMessages()
