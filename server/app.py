from TwilioIntegration import 
from YoutubeIntegration import 
from MessageQueue import 

if __name__ == '__main__':
    app.run(debug=True, host='streams', port="8080")

@app.route("/v1/stream/", methods=['POST'])
def beginStream():
    # CALL mock L1 function
    # CALL mock MQ function
    # CALL mock L2 function


@app.route("/v1/stream/", methods=['DELETE'])
def endStream():
    # PRINT statements