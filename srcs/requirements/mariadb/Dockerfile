FROM debian:bullseye

# Update package lists and install MariaDB server
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    mariadb-server \
    mariadb-client && \
    #apt-get clean && \
    #rm -rf /var/lib/apt/lists/*

# Create directory for MariaDB to run
RUN mkdir -p /var/run/mysqld && \ 
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld
# RUN mkdir -p /var/run/mysqld && \
#     chown -R mysql:mysql /var/run/mysqld && \
#     chown -R mysql:mysql /var/lib/mysql

# Copy initialization script
COPY ./tools/init_mariadb.sh /usr/local/bin/init_mariadb.sh
# # Copy MariaDB configuration file
# COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /usr/local/bin/init_mariadb.sh
RUN /usr/local/bin/init_mariadb.sh

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/init_mariadb.sh"]

# Expose MariaDB port
EXPOSE 3306

# Start MariaDB
CMD ["mysqld", "--bind-address=0.0.0.0"]
# CMD ["mysqld_safe"]


# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

