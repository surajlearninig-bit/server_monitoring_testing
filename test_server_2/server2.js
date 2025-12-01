const express = require("express");
const app = express();
const PORT = 3002;

app.use(express.static("public"));

app.get("/health", (req, res) => {
    res.json({
        status: "OK",
        time: new Date()
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server 2 running on http://0.0.0.0:${PORT}`);
});
