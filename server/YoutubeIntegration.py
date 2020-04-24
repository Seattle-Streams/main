import os

#import google_auth_oauthlib.flow
#import googleapiclient.discovery
#import googleapiclient.errors

scopes = ["https://www.googleapis.com/auth/youtube.force-ssl"]

# Consuming messages from MQ & POSTING to YT Live

# Authenticate w/ YT & store token in Token Store (S3)
def YoutubeAuth():
    # Code from: https://developers.google.com/youtube/v3/live/docs/liveChatMessages/insert?apix=true#http-request
    # Disable OAuthlib's HTTPS verification when running locally.
    # *DO NOT* leave this option enabled in production.
    """   os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

    api_service_name = "youtube"
    api_version = "v3"
    client_secrets_file = "YOUR_CLIENT_SECRET_FILE.json"

    # Get credentials and create an API client
    flow = google_auth_oauthlib.flow.InstalledAppFlow.from_client_secrets_file(
        client_secrets_file, scopes)
    credentials = flow.run_console()
    youtube = googleapiclient.discovery.build(
        api_service_name, api_version, credentials=credentials)
    """
# Is this necessary
# Gets YT auth token from Token Store (S3 in our case) to send requests
def GetStoredToken():
    # TODO: implement this method
    print("Stored Token Got")

# def callback(ch, method, properties, body):
#     print(" [x] Received %r" % body)


# Reshape data
def ShapeMessage(body):
    splitBody = body.split(" ", 1)
    name = splitBody[0]
    message = splitBody[1]
    return name, message

# SEND POST Requests to YT Live
def ProcessMessage(event, context):
    
    # badStatus = True

    print(event)


    """  name, body = ShapeMessage(body)
    # sending POST request, inserting messages into LiveChat
    request = youtube.liveChatMessages().insert(
        part="snippet",
        body={
            "snippet": {
                "liveChatId": "YOUR_LIVE_CHAT_ID",
                "type": "textMessageEvent",
                "textMessageDetails": {
                    "messageText": f"{body}"
                }
            },
            "authorDetails": {
                "displayName": f"{name}"
            },
        })
    response = request.execute()
    data = response.json()
    # TODO: Check that this is the proper way to check response status
    if (data["status"] < 400 & data["status"] > 199):
        # Message was received by Youtube therefore we can continue
    else:
        # Send message to secondary location [comment section of last live stream]
        print("Sending messages to comment section of most recent live stream") """