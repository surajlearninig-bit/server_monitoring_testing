#!/bin/bash

echo "Starting Server 1..."
node /app/my-test-site/server.js &

echo "Starting Server 2..."
node /app/test_server_2/server2.js &

echo "Starting Health Monitor..."
python3 /app/server_health.py
