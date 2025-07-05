FROM debian:bullseye

# Install Redis server and required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    redis-server \
    redis-tools

RUN rm -rf /var/lib/apt/lists/*

# Create Redis data directory and set permissions
RUN mkdir -p /var/lib/redis && \
    chown redis:redis /var/lib/redis && \
    chmod 755 /var/lib/redis

# Create Redis log directory
RUN mkdir -p /var/log/redis && \
    chown redis:redis /var/log/redis

# Expose Redis port (6379 default standard)
EXPOSE 6379

# Switch to redis user for security
# Redis runs as a non-root user (for security)!! so need change!
USER redis

# Start Redis server with inline configuration
CMD ["redis-server", "--bind", "0.0.0.0"] 
