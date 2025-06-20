#!/bin/bash


# stop & remove all containers
echo -e "${GREENB}REMOVING CONTAINERS...${COLOR_RESET}"




# remove all images
echo -e "${GREENB}REMOVING IMAGES...${COLOR_RESET}"


# remove all volumes 
echo -e "${GREENB}REMOVING VOLUMES...${COLOR_RESET}"


# remove all networks 
echo -e "${GREENB}REMOVING NETWORKS...${COLOR_RESET}"


# skip default networks: bridge, host, none
echo -e "${GREENB}REMOVING NETWORKS...${COLOR_RESET}"



# **************************************************************************** #
#                              COLOR SETTING                                   #
# **************************************************************************** #

COLOR_RESET="\033[0m"
GREENB="\033[1;38;5;85m"
REDB="\033[1;91m"