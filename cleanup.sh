#!/bin/bash

# **************************************************************************** #
#                              COLOR SETTING                                   #
# **************************************************************************** #

COLOR_RESET="\033[0m"
GREENB="\033[1;38;5;85m"
REDB="\033[1;91m"

# **************************************************************************** #

# stop & remove all containers (running or stopped)
echo -e "${REDB}REMOVING CONTAINERS...${COLOR_RESET}"
if [ -n "$(docker container ls -aq)" ]; then
    docker container stop $(docker container ls -aq);
    docker container rm $(docker container ls -aq);
fi;


# remove all images
echo -e "${REDB}REMOVING IMAGES...${COLOR_RESET}"
if [ -n "$(docker images -aq)" ]; then
    docker rmi -f $(docker images -aq);
fi;


# remove all volumes 
echo -e "${REDB}REMOVING VOLUMES...${COLOR_RESET}"
if [ -n "$(docker volume ls -q)" ]; then
    docker volume rm "$(docker volumes ls -q)";
fi;


# after cleaning containers & images -> better to do thorough cleanup to better control the files left
docker system prune -a;

# remove all networks 
# skip default networks: bridge, host, none
echo -e "${REDB}REMOVING NETWORKS...${COLOR_RESET}"
CUSTOM_NETWORKS=$(docker network ls --format "{{.Name}}" | grep -v -E "^(bridge|host|none)$")
if [ -n "$CUSTOM_NETWORKS" ]; then
    echo "$CUSTOM_NETWORKS" | xargs docker network rm 2>/dev/null || true
fi

#remove all data directories -> should not need
# echo -e "${REDB}REMOVING DATA DIRECTORIES...${COLOR_RESET}"
# sudo rm -rf /home/yilin42/data


# **************************************************************************** #
#                                    NOTES                                     #
# **************************************************************************** #

# -e : interprets \n, \t, colors
# -n : check if result is not empty

#if [ CONDITION ]; then
  # ~~commands to run if CONDITION is true~~
#fi

# -a : show all containers (running, stopped, etc.)
# -q : quiet mode –> only return container ID (no headers or other details)

# docker container ls -aq : list all container ID
# docker images -aq : show all image ID
# docker volume ls -q : list all volume names/ID (quiet mode)
# docker rm <ids> : remove containers
# docker rmi -f <ids> : FORCE remove images (even if used by stopped containers)

# docker system prune -a : A comprehensive cleanup command -> Deletes unused containers, networks, images, and build cache

# if list all networks, output will be: 
# NETWORK ID     NAME      DRIVER    SCOPE
# 9f4c53bff3d2   bridge    bridge    local
