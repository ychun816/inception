# NOTES

# DOCKER-COMPOSE
## syntax notes
services:
    nginx:
        build: #./requirements/nginx  # Simple form: just the directory path

        build: 
            context: ./requirements/nginx
            dockerfile: Dockerfile

        depends_on:
            - wordpress # This service waits for 'wordpress' service to start first
        
        ports:
        - 443:443 # External HTTPS access 
        #Maps port 443 on your machine to port 443 in container
        #ports is specified when need to map external https access

        volumes:
        - wordpress_data:/var/www/html 
        #named_volume:container_path 
        #Shares data between containers
        
        networks:
            - inception_network
            # Connects to a custom network named "inception-network"


    mariadb:
        ...
        env_file: .env  # Passes ALL variables to container
        #OR
        environment: #specified the variables needed for this container from .env file -> more secured 

## extra syntax options
###  depends_on:
- Adds a service dependency on wordpress, ensuring nginx will wait for wordpress to start first.
- This is especially useful because your Nginx nginx.conf is forwarding PHP requests to fastcgi_pass wordpress:9000.

### restart:
- always
- unless-stopped : more graceful than restart: always. IIt ensures services are not restarted if manually stopped, yet they auto-restart after a failure or reboot
- always : Container restarts automatically if it stops
- unless-stopped :Restart unless manually stopped
- on-failure : Only restart on failure
- no : Never restart

### driver: local	
Use Docker’s default volume driver (local)
### driver_opts:	
Additional options for the volume
### type: none	
Used when mounting a host directory directly (instead of Docker managing it)
### device:	
The path on your host machine to use as the volume
### o: bind	
Bind-mount type: mounts the exact directory you specify (not a managed volume)


# Mandotary Setups

# 1. nginx

# Dockerfile

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

# Config File
#default config file existing in the docker after default nginx install -> /etc/nginx/nginx.conf

# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# listen 443 ssl; → Listens on all IPv4 addresses
# listen [::]:443 ssl; → Listens on all IPv6 addresses
# => This allows Docker’s port forwarding from the host to reach Nginx inside the container

# :: is the IPv6 version of 0.0.0.0 — meaning “all interfaces”

# ssl_certificate: Path to your public SSL certificate (.crt)
# ssl_certificate_key: Path to your private SSL key (.key)
# These are used to encrypt HTTPS traffic.
# Without these, Nginx cannot serve HTTPS.

# root  -> Specifies the base folder Nginx should look into to serve files
# index -> Defines the default file(s) to return when the user visits / # PHP first for WordPress

# /etc : Stores configuration files for system-wide settings and services.
# /etc/nginx/ : Is the default configuration directory for Nginx.
# -> Keep your SSL cert organized / config paths predictable / standard practice for Linux-based servers

# ssl_protocols TLSv1.2 TLSv1.3; 
# -> TLSv1.2 and TLSv1.3 are secure and modern.
# -> Older ones like SSLv3 or TLSv1.0 are disabled for security.

# SPECIFIC HANDLER : wp-admin -> NO NEED SPECIFIED!
# /wp-login.php is a PHYSICAL FILE

# /var : Stores log files
# /var/www/html -> not required; Linux convention
# -> can change to "root /my/project/site;"

# index index.html index.php index.nginx-debian.html;
# -> If someone visits just /, check these files in order, and serve the first one that exists => order MATTER!
# -> Nginx serves: → index.html first → If missing, then index.php → If both missing, then index.nginx-debian.html
# -> Required to specify all three. You can specify only the one(s) your site actually uses.

#try_files $uri $uri/ /index.php$is_args$args;
# $uri → The requested URL path
# $uri/ → Directory version (for folders)
# $is_args$args → Appends query strings (?id=123 etc.)
# Try the following in order:
# 1. Does the exact file exist? ($uri)
# 2. Does a folder exist? ($uri/)
# 3. If not, forward to index.php, passing URL parameters.

# Host	: Original domain name	-> value: yilin.42.fr
# X-Real-IP : Original client IP -> value: 192.168.1.100
# X-Forwarded-For : Chain of proxy IPs -> value: 192.168.1.100, 10.0.0.1
# X-Forwarded-Proto : Original protocol	value-> https



<!-- -------- -->

# 2. wordpress

## Dockerfile


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



<!-- -------- -->

# 3. mariaDB

## bash script syntax
### ! -d : 
Test if the directory does not exist
### /var/lib/mysql/mysql : 
Default location for system tables (if this folder exists, MariaDB is already initialized)
### --user=mysql : 
Run initialization as the mysql user
### --datadir :
- Set the directory where the database files are stored
- Create necessary system tables (like mysql.user)

### mysqld_safe : 
Wrapper that adds logging and auto-restart features
### & : 
Run the command in the background

### mysqladmin ping : 
Pings the server to check if it's alive
### -u root : 
Connects as root
### -p"${MYSQL_ROOT_PASSWORD}" : 
Uses root password (from env var)
### until : 
Loop until the command succeeds
### -e "USE ..." : 
Executes the SQL statement
### ! : 
Negates the result —> so if the database doesn’t exist, it runs the next block

## Dockerfile

### mysqld: 
The MariaDB server daemon
### --bind-address=0.0.0.0:
-> Configures the server to listen on all network interfaces
-> Allows external connections (not just localhost)

<!-- -------- -->


