import requests
import os

import google_auth_oauthlib.flow
import googleapiclient.discovery
import googleapiclient.errors

scopes = ["https://www.googleapis.com/auth/youtube.force-ssl"]

# Consuming messages from MQ & POSTING to YT Live
class YoutubeIntegration:
    def __init__(self, authToken):
        self.authToken = authToken
        
    # Authenticate w/ YT & store token in Token Store (S3)
    def YoutubeAuth():
        # Code from: https://developers.google.com/youtube/v3/live/docs/liveChatMessages/insert?apix=true#http-request
        # Disable OAuthlib's HTTPS verification when running locally.
        # *DO NOT* leave this option enabled in production.
        os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

        api_service_name = "youtube"
        api_version = "v3"
        client_secrets_file = "YOUR_CLIENT_SECRET_FILE.json"

        # Get credentials and create an API client
        flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(
            client_secrets_file, scopes)
        credentials = flow.run_console()
        youtube = googleapiclient.discovery.build(
            api_service_name, api_version, credentials=credentials)
        
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
        
        badStatus = True
    
        splitMessage = message.split(" ", 1)
        name = splitMessage[0]
        body = splitMessage[1]
            
        while badStatus:
            # sending POST request, inserting messages into LiveChat
            request = youtube.liveChatMessages().insert(
                part="snippet",
                body={
                "snippet": {
                    "liveChatId": "YOUR_LIVE_CHAT_ID",
                    "type": "textMessageEvent",
                    "textMessageDetails": {
                    "messageText": "{body}"
                    }
                },
                "authorDetails": {
                    "displayName": "{name}"
                },
                }
            )
            response = request.execute()
            data = response.json()
            # TODO: Check that this is the proper way to check response status
            if (data["status"] < 400 & data["status"] > 199):
                badStatus = False
            else:
                # re-authenticate to generate auth token



    def ProcessMessages():   
        # Connect to MQ

        # PULL Messages from MQ
        ConsumeMessages()

        # Reshape data
        ShapeMessages()

        # SEND POST Requests to YT Live
        POSTMessages()

