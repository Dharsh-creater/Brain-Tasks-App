const http = require('http');
const fs = require('fs');
const path = require('path');

const server = http.createServer((req, res) => {
    console.log(`Request: ${req.method} ${req.url}`);
    
    let filePath = '.' + req.url;
    if (filePath === './') {
        filePath = './index.html';
    }
    
    console.log(`Looking for file: ${filePath}`);
    console.log(`Current directory: ${__dirname}`);
    
    const fullPath = path.join(__dirname, filePath);
    console.log(`Full path: ${fullPath}`);
    
    fs.readFile(fullPath, (error, content) => {
        if (error) {
            console.log(`Error: ${error.code} - ${error.message}`);
            if(error.code === 'ENOENT') {
                res.writeHead(404);
                res.end('File not found: ' + filePath);
            } else {
                res.writeHead(500);
                res.end('Server Error: ' + error.code);
            }
        } else {
            console.log(`Serving file: ${filePath}`);
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(content, 'utf-8');
        }
    });
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
    console.log(`Serving files from: ${__dirname}`);
}); 