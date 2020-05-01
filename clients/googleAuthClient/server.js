const https = require('https');
const fs = require("fs");
 
const options = {
  key: fs.readFileSync('key.pem'),
  cert: fs.readFileSync('cert.pem')
};

https.createServer(options, (request, response) => {
    fs.readFile("index.html", (err, data) => {
        response.writeHead(200, {'Content-Type': 'text/html'});
        response.write(data);
        response.end();
      });
}).listen(3000);