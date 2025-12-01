#!/usr/bin/env python3
from http.server import BaseHTTPRequestHandler, HTTPServer
import subprocess

PORT = 8082

class HealthHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()

        # Run health script
        output = subprocess.getoutput("/home/robo/projects/usage.sh")

        # HTML page
        html = f"""
        <html>
        <head>
            <title>Server Health Monitor</title>
            <meta http-equiv="refresh" content="3">
            <style>
                body {{ font-family: monospace; background-color: #f0f0f0; padding: 20px; }}
                h2 {{ color: #003366; }}
                h3 {{ margin-bottom: 5px; }}
            </style>
        </head>
        <body>
            <h2>Linux Server Health Monitor (Test Automation Site)</h2>
            {output}
        </body>
        </html>
        """
        self.wfile.write(html.encode('utf-8'))

# Start server
with HTTPServer(("", PORT), HealthHandler) as server:
    print(f"Serving at port {PORT}")
    server.serve_forever()
