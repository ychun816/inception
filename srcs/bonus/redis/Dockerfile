# Use Debian Bullseye as base image (consistent with other services)
FROM debian:bullseye

# Install Redis server and required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    redis-server \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Create Redis data directory and set permissions
RUN mkdir -p /var/lib/redis && \
    chown redis:redis /var/lib/redis && \
    chmod 755 /var/lib/redis

# Create Redis log directory
RUN mkdir -p /var/log/redis && \
    chown redis:redis /var/log/redis

# Expose Redis port
EXPOSE 6379

# Switch to redis user for security
USER redis

# Start Redis server with inline configuration
# --bind 0.0.0.0: Allow connections from any IP (for container networking)
# --port 6379: Default Redis port
# --dir /var/lib/redis: Data directory
# --logfile /var/log/redis/redis.log: Log file location
# --loglevel notice: Moderate logging level
# --save 900 1: Save if at least 1 key changed in 900 seconds
# --save 300 10: Save if at least 10 keys changed in 300 seconds
# --save 60 10000: Save if at least 10000 keys changed in 60 seconds
CMD ["redis-server", \
     "--bind", "0.0.0.0", \
     "--port", "6379", \
     "--dir", "/var/lib/redis", \
     "--logfile", "/var/log/redis/redis.log", \
     "--loglevel", "notice", \
     "--save", "900", "1", \
     "--save", "300", "10", \
     "--save", "60", "10000", \
     "--maxmemory", "256mb", \
     "--maxmemory-policy", "allkeys-lru"] 