# 1. Base Image
FROM node:18

# 2. Working Directory
WORKDIR /app

# 3. Copy Files
COPY . .

# 4. Install Python & System Tools
RUN apt-get update && apt-get install -y python3 procps

# 5. Install Node Dependencies
RUN cd /app/my-test-site/ && npm install && cd /app/test_server_2/ && npm install

# 6. Expose Ports
EXPOSE 3000 3002 8082

# 7. Permissions setup
RUN chmod +x /app/start.sh && chmod +x /app/usage.sh

# 8. Start Everything
CMD ["bash", "/app/start.sh"]
