FROM debian:bullseye

# Update package lists and install MariaDB server
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    mariadb-server \
    mariadb-client && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy MariaDB configuration file
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copy initialization script
COPY tools/init_db.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/init_db.sh

# Create directory for MariaDB to run
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chown -R mysql:mysql /var/lib/mysql

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/init_db.sh"]

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB
CMD ["mysqld_safe"]