# Use Debian Bullseye as base image (consistent with other services)
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
# RUN mkdir -p /var/www/html/adminer && \
#     curl -sSLo /var/www/html/adminer/index.php https://www.adminer.org/latest.php
RUN mkdir -p /var/www/html && \
    curl -sSLo /var/www/html/index.php \
    https://www.adminer.org/latest.php

# Configure Apache to serve /adminer/
# RUN echo '<VirtualHost *:80>
#     DocumentRoot /var/www/html
#     <Directory /var/www/html/adminer>
#         Options Indexes FollowSymLinks
#         AllowOverride All
#         Require all granted
#     </Directory>
# </VirtualHost>' > /etc/apache2/sites-available/000-default.conf



# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Expose Apache port
EXPOSE 80
#7000 

# Start Apache in foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]

# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# mkdir -p
# altho /var/www/html already exist,
# -> defensive programming: ensures the path exists in case of image changes or layering differences
# -p avoids errors if the directory already exists.

# install Adminer into your web directory so Apache can serve it
# downloads the latest Adminer PHP file and places it directly into the web root (/var/www/html) as index.php
# -sS: silent mode, but still shows errors
# -L: follows redirects (in case the URL redirects)
# -o: output to a file

# a2enmod : enable Apache modules.
# 'rewrite': needed for clean URLs.
# 'php7.4' : load the PHP interpreter module into Apache.
# In most modern builds, just enabling `php` is safer.


# -R : "recursive" -> apply to the specified directory and all its contents (files and subdirectories) inside it
# user:group
# chown -R : changes ownership of /var/www/html and every file and folder inside it to user www-data and group www-data
# chmod -R 755 :
#  - owner: read/write/execute
#  - group + others: read/execute



# 80 : standard HTTP port ->  Apache defaults to port 80 (standard for web apps)
# Most people leave Apache on port 80 and use Docker’s ports: in docker-compose.yml to map to other host ports (e.g., 8080:80) 


# "apache2ctl" : the command to control/start Apache.
# -D: tells Apache to define a configuration flag.
# FOREGROUND: instructs Apache not to daemonize (i.e., stay in the foreground).


# DOWNLOADED TOOLS:
# apache2           # Web server (serves pages)
# php               # PHP interpreter (runs code)
# php-mysql         # Connects PHP to MySQL/MariaDB
# php-mysqli        # Alternative MySQL connection method
# php-pdo           # Database abstraction layer
# php-pdo-mysql     # PDO driver for MySQL/MariaDB