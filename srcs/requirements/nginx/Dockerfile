
# Use the official Debian Bullseye base image as the starting point for this container. #:[version]
FROM debian:bullseye

# Install required packages! & clean up in a single layer -> every RUN creates new layer -> better keep it thin!
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    procps

# Create the directory /etc/nginx/ssl if it doesn't already exist.
# This folder will store SSL certificates and keys for nginx.
RUN mkdir -p /etc/nginx/ssl

# openssl package installed -> generate certificate
RUN openssl req -x509 \
           -newkey rsa:2048 -nodes \
           -days 365 \
           -keyout /etc/nginx/ssl/inception.key \
           -out /etc/nginx/ssl/inception.crt \ 
           -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=yilin.42.fr"

#RUN rm -rf /var/lib/apt/lists/*
    #apt clean

# COPY <source> <destination>
# copy files from the local build context into the root directory of (the docker) image.
COPY nginx.conf /etc/nginx/nginx.conf

# Create the /run/nginx directory -> typically used by nginx to store the PID file and runtime data.
RUN mkdir -p /run/nginx

# Inform Docker and users that the container will listen on port 443 (standard port for HTTPS).
EXPOSE 443

# Default command to run when the container starts.
CMD ["nginx", "-g", "daemon off;"]
