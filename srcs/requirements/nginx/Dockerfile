
# using the existing docker image from the docker hub, :[version]
FROM debian:bullseye


# install nginx
RUN apt-get update && \
    apt-get install -y nginx openssl 
    #&& \
    #apt clean

# copy files from the local build context into the root directory of (the docker) image.
# COPY <source> <destination>
COPY nginx.conf /etc/nginx/nginx.conf

