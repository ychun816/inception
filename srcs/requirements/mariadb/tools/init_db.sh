#!/bin/bash

# MariaDB Initialization Script

set -e

echo "Starting MariaDB initialization..."

# Start MariaDB in background for setup
mysqld_safe --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &
mysql_pid=$!

# Wait for MariaDB to start
echo "Waiting for MariaDB to start..."
until mysqladmin ping --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

echo "MariaDB started. Setting up database..."

# Set root password and create database
mysql -u root <<EOF
-- Set root password
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

-- Create database
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Create user and grant privileges
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Allow root access from any host (for development)
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Flush privileges
FLUSH PRIVILEGES;
EOF

echo "Database setup completed successfully!"

# Stop the background MariaDB process
kill $mysql_pid
wait $mysql_pid

echo "Starting MariaDB in foreground mode..."

# Start MariaDB in foreground
exec mysqld_safe --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock
