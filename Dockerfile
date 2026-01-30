# Use a lightweight Nginx image
FROM nginx:alpine

# Remove default nginx static files
RUN rm -rf /usr/share/nginx/html/*

# Copy your WebSocket client into the nginx web root
COPY ./index.html /usr/share/nginx/html/index.html

# Expose port 80 for the container
EXPOSE 10000

# Nginx runs automatically as the container's CMD
