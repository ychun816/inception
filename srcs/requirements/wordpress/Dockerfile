FROM debian:bullseye

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    wget \
    curl \
    bash \
    php \
    php-cgi \
    php-mysql \
	php-fpm \
    php-pdo \
    php-gd \
    php-cli \
    php-mbstring

# Add MySQL Client 
RUN apt-get install -y default-mysql-client

# Download WP-CLI -> make it executable -> move it to a directory in the PATH
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy custom PHP-FPM pool configuration into container
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/

# Create runtime directory required by PHP-FPM
RUN mkdir /run/php

# Copy custom WordPress setup script into container
COPY ./tools/init_wordpress.sh /usr/local/bin/

# Make the WordPress setup script executable
RUN chmod +x /usr/local/bin/init_wordpress.sh

# Set the entrypoint script -> run automatically when the container start
ENTRYPOINT ["/usr/local/bin/init_wordpress.sh"]

# Set the working directory inside the container
WORKDIR /var/www/html/

# Inform Docker that the container will listen on port 9000 (used by PHP-FPM)
EXPOSE 9000

# Start PHP-FPM in FOREGROUND mode to keep the container running
CMD ["/usr/sbin/php-fpm7.4", "-F"]
