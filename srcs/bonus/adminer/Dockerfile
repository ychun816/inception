FROM debian:bullseye

# Install Apache/ PHP / required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    apache2 \
    php \
    php-mysql \
    php-mysqli \
    php-pdo \
    php-pdo-mysql \
    php-json \
    php-mbstring \
    curl \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Enable Apache modules
RUN a2enmod rewrite php7.4

# Fix Apache ServerName warning
# RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo "DirectoryIndex index.php" >> /etc/apache2/apache2.conf

# Download Adminer to ROOT instead of subfolder
RUN mkdir -p /var/www/html && \
    curl -sSLo /var/www/html/index.php \
    https://www.adminer.org/latest.php

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose Apache port
EXPOSE 80
#7000 

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]
