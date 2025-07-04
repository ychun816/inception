# Use Debian Bullseye as base image (consistent with other services)
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


# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# apt-get install -y redis-server redis-tools: Installs Redis and its CLI tools
# rm -rf /var/lib/apt/lists/*: Cleans up cached package lists to reduce image size

# redis:redis -> changes the owner of the directory to the redis system user and group
# chown : ensures the Redis process has the permissions to read/write data and logs

# 755 : 
# Owner (redis): read (r), write (w), execute (x)
# Group: read (r), execute (x)
# Others: read (r), execute (x)
# Directories need x (execute) permission to traverse into them. Without x, even reading file names inside fails.


# default port:
# Redis listens on 6379 standard port 
# HTTP -> 80
# HTTPS -> 443

# USER redis
# -> best practice : always run apps with the least privilege they need

# "redis-server" : Redis’s main server process (daemon)
# "--bind" :  Tells Redis which IP address(es) it should listen on for incoming connections.
# "0.0.0.0": Allow connections from any IP (for container networking)

# EXTRA FLAGS
# --logfile /var/log/redis/redis.log: Log file location
# --loglevel notice: Moderate logging level
# --save 900 1: Save if at least 1 key changed in 900 seconds
# --save 300 10: Save if at least 10 keys changed in 300 seconds
# --save 60 10000: Save if at least 10000 keys changed in 60 seconds