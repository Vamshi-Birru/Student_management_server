const http = require('http');
// Load contract ABI from file
const contractAddress = require('./contractAddress.json'); // Load contract address from file
const Agent=require("../artifacts/contracts/Agent.sol/Agent.json");
const contractABI = Agent.abi;

async function main() {
    // Your main logic here
    console.log("Main function executed successfully");

    // Start the server after the main logic completes
    startServer();
}

function startServer() {
    const server = http.createServer((req, res) => {
        // Set CORS headers
        res.setHeader('Access-Control-Allow-Origin', '*'); // Allow requests from any origin
        res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS'); // Allow GET, POST, OPTIONS requests
        res.setHeader('Access-Control-Allow-Headers', 'Content-Type'); // Allow Content-Type header

        if (req.url === '/contract-info') {
            res.writeHead(200, { 'Content-Type': 'application/json' });
            const contractInfo = { contractABI, contractAddress };
            res.end(JSON.stringify(contractInfo));
        } else {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('Not found');
        }
    });

    const PORT = 5000;
    server.listen(PORT, () => {
        console.log(`Server running at http://localhost:${PORT}`);
    });

    // Handle process termination signals
    process.on('SIGINT', () => {
        console.log('Received SIGINT. Closing server...');
        server.close(() => {
            console.log('Server closed.');
            process.exit(0);
        });
    });
}

main()
    .then(() => console.log("Server initialization complete"))
    .catch(error => {
        console.error("Error in main function:", error);
        process.exit(1); // You might want to exit with an error code here
    });
