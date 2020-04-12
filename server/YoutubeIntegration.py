import requests

# Consuming messages from MQ & POSTING to YT Live
class YoutubeIntegration:
    def __init__(self, authToken):
        self.authToken = authToken
        
    # Authenticate w/ YT & store token in Token Store (S3)
    def YoutubeAuth():
        
    # Gets YT auth token from Token Store (S3 in our case) to send requests
    def GetStoredToken():

    # PULL Messages from MQ
    def ConsumeMessages():

    # Reshape data
    def ShapeMessages():

    # SEND POST Requests to YT Live
    def POSTMessages(messages):
        # IF token is expired,
        if ():
            # re-authenticate with YT
            # Store auth token in Token Store (S3)
        
        statusOK = True
        while (!statusOK):
            # POSTing Messages
            URL = "https://www.googleapis.com/youtube/v3/liveChat/messages"
            PARAMS = {'param_key':param_value} 
            
            # sending get request and saving the response as response object 
            response = requests.POST(url = URL, params = PARAMS) 
            # extracting data in json format 
            data = response.json()
            if ():
                statusOK = false


    def ProcessMessages():   
        # Connect to MQ

        # PULL Messages from MQ
        ConsumeMessages()

        # Reshape data
        ShapeMessages()

        # SEND POST Requests to YT Live
        POSTMessages()

    