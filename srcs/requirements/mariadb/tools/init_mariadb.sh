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
#                              COLOR SETTING                                   #
# **************************************************************************** #

COLOR_RESET="\033[0m"
GREENB="\033[1;38;5;85m"
REDB="\033[1;91m"
