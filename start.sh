#!/bin/bash

echo "Starting Server 1..."
cd /app/my-test-site/ && node server.js &

echo "Starting Server 2..."
cd /app/test_server_2/ && node server2.js &

echo "Starting Health Monitor..."
python3 /app/server_health.py
