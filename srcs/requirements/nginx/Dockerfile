
# Use the official Debian Bullseye base image as the starting point for this container.
# using the existing docker image from the docker hub, :[version]
FROM debian:bullseye

# install nginx
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


# copy files from the local build context into the root directory of (the docker) image.
# COPY <source> <destination>
COPY nginx.conf /etc/nginx/nginx.conf

# Create the /run/nginx directory -> typically used by nginx to store the PID file and runtime data.
RUN mkdir -p /run/nginx

# Inform Docker and users that the container will listen on port 443 (standard port for HTTPS).
EXPOSE 443

# Default command to run when the container starts.
CMD ["nginx", "-g", "daemon off;"]


# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# 'apt-get update' updates the package lists for available packages.
# 'apt-get upgrade -y' upgrades all installed packages to their latest versions automatically.
# 'apt install -y ...' installs the listed packages without prompting for confirmation:
#   - openssl: tool for SSL/TLS certificates and cryptography
#   - procps: utilities for process monitoring (e.g., ps, top)
#   --no-install-recommends : tells apt not to install these recommended extra packages, only the essential dependencies.
#   => keep your image lean and avoid extra utilities or libraries


# | Flag               | Meaning                                           |
# | ------------------ | ------------------------------------------------- |
# | `-x509`            | Output a self-signed certificate instead of a CSR |
# | `-newkey rsa:2048` | Generate a new private key (2048 bits, RSA)       |
# | `-nodes`           | No passphrase (unencrypted key)                   |
# | `-keyout <file>`   | Where to save the private key                     |
# | `-out <file>`      | Where to save the certificate                     |
# | `-days 365`        | Certificate validity duration                     |
# | `-subj "..."`      | Provide subject info (Version 1 only /                                                                       |    
# |                    | specifies the certificate subject (Country, State, Location, Organization, Organizational Unit, Common Name) |


# mkdir -p : "create parent directories as needed" -> It prevents errors if the path already exists
# /run/nginx : 
# (1) Nginx needs /run/nginx/nginx.pid to store its process ID
# (2) If /run/nginx doesn't exist, Nginx will fail to start.
# (3) It's a temporary runtime directory — recreated every boot on Linux systems.


# ["nginx", "-g", "daemon off;"] : exec form of CMD, not shell form; passed directly to the kernel as an array of arguments
# Starts nginx with the flag '-g daemon off;' -> keeps nginx running in the foreground,
# necessary for Docker to keep the container alive.


# docker-compose.yml is for orchestration — how containers run, link, and interact.
# Cleanup like apt-get clean, rm -rf /var/lib/apt/lists/*, etc., affects image size, which is managed by the Dockerfile.
# Once the image is built, docker-compose just starts containers based on that image — it's too late to clean up.