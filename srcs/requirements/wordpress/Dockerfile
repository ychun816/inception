FROM debian:bullseye

# Update package lists, upgrade existing packages, and install required packages
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

# Download WP-CLI -> make it executable -> move it to a directory in the PATH
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copy custom PHP-FPM pool configuration into container
COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/

# Create runtime directory required by PHP-FPM
RUN mkdir /run/php

# Copy custom WordPress setup script into container
COPY ./tools/setup_wordpress.sh /usr/local/bin/

# Make the WordPress setup script executable
RUN chmod +x /usr/local/bin/setup_wordpress.sh

# Set the entrypoint script -> run automatically when the container start
ENTRYPOINT ["/usr/local/bin/setup_wordpress.sh"]

# Set the working directory inside the container
WORKDIR /var/www/html/

# Inform Docker that the container will listen on port 9000 (used by PHP-FPM)
EXPOSE 9000

# Start PHP-FPM in FOREGROUND mode to keep the container running
CMD ["/usr/sbin/php-fpm7.4", "-F"]


# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# apt-get update : Update the list of available packages from Debian’s package sources.
# apt-get upgrade -y : Upgrade all installed packages to their latest versions.
# apt-get install -y \ ... : Install a list of useful tools and PHP components.
    # wget \                  # Tool for downloading files over HTTP/HTTPS/FTP
    # curl \                  # Tool for making web requests from command line
    # bash \                  # Shell for running scripts
    # php \                   # Core PHP interpreter
    # php-cgi \               # PHP interface for web servers (Common Gateway Interface)
    # php-mysql \             # PHP module to connect with MySQL databases
    # php-fpm \               # PHP FastCGI Process Manager for serving PHP via sockets/ports
    # php-pdo \               # PHP Data Objects for abstract database access
    # php-gd \                # PHP module for image manipulation
    # php-cli \               # Command-line interface for PHP
    # php-mbstring            # PHP support for multibyte strings (needed by WordPress)


# curl -O <URL>	: Downloads a file from the internet using curl. -O / tells it to save with the original file name.	-> It grabs the WP-CLI tool from GitHub.
# Renames and moves the file into /usr/local/bin -> puts file in system's PATH -> so you can just type wp in the terminal to run it.



# The php-fpm service creates a default pool, the configuration (<www.conf>) for which can be found in /etc/php/7.4/fpm/pool.d folder. 
# You can customize the default pool as per your requirements. 
# pool.d holds individual pool configuration files.

# Conventional Unix practice: executables in /usr/local/bin are added to PATH, so you can run them as commands. -> i.e. minishell



# RUN is used to build the image and install software, CMD provides default commands for container execution, and ENTRYPOINT sets the main command for the container. 

# ENTRYPOINT ["executable", "param1", "param2"] => The shell form: ENTRYPOINT command param1 param2
# WORKDIR : If not specified, the default working directory is / -> 


# Linux directory structure:
# /bin  : binary or executable programs.
# /etc  : system configuration files.
# /home : home directory. It is the default current directory.
# /opt  : optional or third-party software.
# /tmp  : temporary space, typically cleared on reboot.
# /usr  : User related programs.
# /var  : log files.

# /run	: stores volatile runtime data.
# /proc	: a virtual and pseudo-file system to contains info about the running processes with a specific process ID or PID.
# /sys	: a virtual file system for modern Linux distributions to store and allows modification of the devices connected to the system.