const http = require("http");

const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {

    if (req.url === "/health") {

        res.writeHead(200, {
            "Content-Type": "application/json"
        });

        res.end(JSON.stringify({
            status: "UP"
        }));

        return;
    }

    res.writeHead(200, {
        "Content-Type": "text/plain"
    });

    res.end("Hello from Production ECS CI/CD!\n");
});

server.listen(PORT, "0.0.0.0", () => {
    console.log(`Application running on port ${PORT}`);
});

