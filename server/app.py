from TwilioIntegration import 
from YoutubeIntegration import 
from MessageQueue import 
from flask import Flask, request
from flask_api import status

app = Flask(__name__)
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0

if __name__ == '__main__':
    app.run(debug=True, host='streams', port="8080")

@app.route("/v1/stream/", methods=['POST'])
def beginStream():
    # CALL mock Twilio Integration function
    
    # CALL mock MQ function
    # CALL mock YT Integration function


@app.route("/v1/stream/", methods=['DELETE'])
def endStream():
    # PRINT statements