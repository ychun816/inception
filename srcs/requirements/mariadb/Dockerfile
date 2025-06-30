FROM debian:bullseye

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
	mariadb-server \
	mariadb-client

RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY ./tools/init_mariadb.sh /usr/local/bin/init_mariadb.sh

# Make init script executable
RUN chmod +x /usr/local/bin/init_mariadb.sh

# Declares that this container will use port 3306 (default port for MariaDB)
EXPOSE 3306

# ENTRYPOINT defines the default executable that runs when the container starts
# This script initializes the database and handles runtime logic
ENTRYPOINT ["/usr/local/bin/init_mariadb.sh"]

# CMD provide default arguments to the ENTRYPOINT script
CMD ["mysqld", "--bind-address=0.0.0.0"]


# **************************************************************************** #
#                                  NOTES                                       #
# **************************************************************************** #

# ENTRYPOINT
# NOTE: You should make sure `/usr/local/bin/mariadb.sh` exists in the image
# If not, the container will fail to run

# mysqld: The MariaDB server daemon
# --bind-address=0.0.0.0:
# -> Configures the server to listen on all network interfaces
# -> Allows external connections (not just localhost)