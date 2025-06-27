#!/bin/bash

# initialize the MariaDB database if dont exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Start mariaDB server
mysqld_safe --datadir=/var/lib/mysql &

# wait for mariadb server to become available
until mysqladmin ping -uroot -p"${MYSQL_ROOT_PASSWORD}" --silent; do
    echo "Waiting for MariaDB..."
    sleep 5
done

# check if database exists
if ! mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" -e "USE ${MYSQL_DATABASE}"; then
    echo "Setting up MariaDB..."
    mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" <<END
    -- Set root password and disable remote root login
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User=''; -- Remove anonymous users
    DROP DATABASE IF EXISTS test; -- Remove test database
    FLUSH PRIVILEGES;

    -- Allow root to connect from any host
    GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;

    -- Create initial database and user with privileges
    CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
END

    if [ -f /usr/local/bin/wordpress.sql ]; then
        mysql -uroot -p"${MYSQL_ROOT_PASSWORD}" "${MYSQL_DATABASE}" < /usr/local/bin/wordpress.sql
    fi
fi

# shut down mariaDB server
mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

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
#                                  NOTES                                       #
# **************************************************************************** #


