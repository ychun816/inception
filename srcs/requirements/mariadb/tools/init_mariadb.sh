#!/bin/bash

# initialize the MariaDB database if not xist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "${GREENB}INITIALIZING MariaDB...${COLOR_RESET}"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start mariaDB server
mysqld_safe --datadir=/var/lib/mysql &

# wait for mariadb server to become available
until mysqladmin ping -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    echo "${GREENB}WAITING FOR MariaDB...${COLOR_RESET}"
    sleep 5
done

# check if database exist
# Start a heredoc -> send multiple SQL commands to MariaDB
# All lines until END are passed to the mysql command
if ! mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${MYSQL_DATABASE}"; then
    echo "${GREENB}SETTING UP MariaDB...${COLOR_RESET}"
    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<END
    -- Set root password and disable remote root login
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    -- Remove anonymous users
    DELETE FROM mysql.user WHERE User='';
    -- Remove test database
    DROP DATABASE IF EXISTS test;
    -- Reloads the user and privilege tables so changes take effect
    FLUSH PRIVILEGES;

    -- Allow root to connect from any host
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;

    -- Create initial database and user with privileges
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
END

# Check if WordPress SQL file exist (for optional DB import)
    if [ -f /usr/local/bin/wordpress.sql ]; then
        mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < /usr/local/bin/wordpress.sql
    fi
fi

# shut down mariaDB server after setup is down
mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

# Replace current script process with whatever command was passed in (usually from Docker CMD)
# Keep container running with MariaDB when start normally
exec "$@"

# **************************************************************************** #
#                                  V2                                          #
# **************************************************************************** #
# MariaDB Initialization Script

# set -e

# echo "Starting MariaDB initialization..."

# # Start MariaDB in background for setup
# mysqld_safe --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &
# mysql_pid=$!

# # Wait for MariaDB to start
# echo "Waiting for MariaDB to start..."
# until mysqladmin ping --silent; do
#     echo "Waiting for MariaDB..."
#     sleep 2
# done

# echo "MariaDB started. Setting up database..."

# # Set root password and create database
# mysql -u root <<EOF
# -- Set root password
# ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

# -- Create database
# CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

# -- Create user and grant privileges
# CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
# GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

# -- Allow root access from any host (for development)
# CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
# GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

# -- Flush privileges
# FLUSH PRIVILEGES;
# EOF

# echo "Database setup completed successfully!"

# # Stop the background MariaDB process
# kill $mysql_pid
# wait $mysql_pid

# echo "Starting MariaDB in foreground mode..."

# # Start MariaDB in foreground
# exec mysqld_safe --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock


# **************************************************************************** #
#                              COLOR SETTING                                   #
# **************************************************************************** #

COLOR_RESET="\033[0m"
GREENB="\033[1;38;5;85m"
REDB="\033[1;91m"


# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# ! -d : Test if the directory does not exist
# /var/lib/mysql/mysql : Default location for system tables (if this folder exists, MariaDB is already initialized)
# --user=mysql : Run initialization as the mysql user
# --datadir : Set the directory where the database files are stored
# => Create necessary system tables (like mysql.user)


# mysqld_safe : Wrapper that adds logging and auto-restart features
#  & : Run the command in the background

# mysqladmin ping : Pings the server to check if it's alive
# -u root : Connects as root
# -p"${MYSQL_ROOT_PASSWORD}" : Uses root password (from env var)
# --silent : Suppresses output
# until : Loop until the command succeeds

# -e "USE ..." : Executes the SQL statement
# ! : Negates the result — so if the database doesn’t exist, it runs the next block