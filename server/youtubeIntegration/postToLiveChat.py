import os


from googleapiclient import discovery
import httplib2
from oauth2client import client
import googleapiclient.errors

DEVELOPER_KEY = "AIzaSyDqjJQGguXp3HH8kOXWVeNmrdcho5hlj8Y"
SCOPES = ["https://www.googleapis.com/auth/youtube.readonly", "https://www.googleapis.com/auth/youtube.force-ssl"]
API_SERVICE_NAME = "youtube"
API_VERSION = "v3"
CLIENT_SECRET_FILE = "client_secret.json"


AUTH_CODE = ""
MESSAGE = "Hello World!"


# getLiveChatID gets the liveChatID of the currently streaming broadcast
def getLiveChatID(youtubeObject) -> str:
    request = youtubeObject.liveBroadcasts().list(
        part="snippet", # available: snippet, status broadcastContent (spelling?)
        broadcastType="all",
        mine=True # only the broadcasts corresponding to authenticated user
    )
    response = request.execute()
    liveChatID = response.items.snippet.liveChatId
    return liveChatID

# postMessage inserts the specified message into the livechat corresponding with the given liveChatID
def postMessage(youtubeObject, liveChatID, message) -> str:
    request = youtubeObject.liveChatMessages().insert(
        part="snippet",
        body={
          "snippet": {
            "liveChatId": liveChatID,
            "type": "textMessageEvent",
            "textMessageDetails": {
              "messageText": message
            }
          }
        }
    )
    response = request.execute()

    return response

# auth authenticates with the provided client secrets file, scope, and authorization code
# returns youtube client object
def auth():
    
    # for production
    # (Receive auth_code by HTTPS POST)

    # for production
    # If this request does not have `X-Requested-With` header, this could be a CSRF
    # if not request.headers.get('X-Requested-With'):
    #     abort(403)

    
    
    # Disable OAuthlib's HTTPS verification when running locally.
    # *DO NOT* leave this option enabled in production.
    os.environ["OAUTHLIB_INSECURE_TRANSPORT"] = "1"

    # Get credentials and create an API client
    # fow now, we will not be using Oauth flow to authenticate
    # (simply using developer api key instead)
    
    credentials = client.credentials_from_clientsecrets_and_code(
    CLIENT_SECRET_FILE,
    SCOPES,
    AUTH_CODE)
    
    authorization_url, state = flow.authorization_url(
        acces_type='offline',
        include_granted_scopes='true')

    youtube = googleapiclient.discovery.build(
        API_SERVICE_NAME, API_VERSION, credentials=credentials)

    youtube = googleapiclient.discovery.build(API_SERVICE_NAME, API_VERSION, developerKey=DEVELOPER_KEY)
    return youtube

def main():
    
    youtubeObject = auth()
    liveChatID = getLiveChatID(youtubeObject)
    response = postMessage(youtubeObject, liveChatID, MESSAGE)
    print(response)

main()