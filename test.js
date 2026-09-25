const assert = require("assert");
const http = require("http");

const options = {
    hostname: "127.0.0.1",
    port: 3000,
    path: "/health",
    method: "GET"
};

const request = http.request(options, (response) => {

    let data = "";

    response.on("data", (chunk) => {
        data += chunk;
    });

    response.on("end", () => {

        try {

            assert.strictEqual(response.statusCode, 200);

            const result = JSON.parse(data);

            assert.strictEqual(result.status, "UP");

            console.log("All tests passed!");

        } catch (error) {

            console.error("Tests failed!");
            console.error(error);

            process.exit(1);
        }
    });
});

request.on("error", (error) => {

    console.error("Application is not running.");
    console.error(error);

    process.exit(1);
});

request.end();

