# **************************************************************************** #
#                                 DIRECTORIES                                  #
# **************************************************************************** #

DATA_DIR = $(HOME)/data
MARIADB_DATA = $(DATA_DIR)/mariadb_data/
WORDPRESS_DATA = $(DATA_DIR)/wordpress_data/




# **************************************************************************** #
#                              SRC & OBJ FILES                                 #
# **************************************************************************** #

COMPOSE_FL = ./src/docker-compose.yml
DOCKER_CLEAN = ./cleanup.sh

# **************************************************************************** #
#                               BUILD COMMANDS                                 #
# **************************************************************************** #

### Build Targets ###
all: up

up:
	mkdir -p 

### CLEANUP ###

clean:
	@$(RM) $(OBJS_DIR)
	@echo "$(BABEBLUEB)🧹 CLEAN DONE! OBJS FILES REMOVED 🧹$(COLOR_RESET)"


fclean: clean

	@echo "$(BABEBLUEB)🫧 FCLEAN DONE! [ $(NAME) ] REMOVED 🫧$(COLOR_RESET)"

### Rebuild ###
re: fclean 
	@echo "$(REDB)RE DONE$(COLOR_RESET)"

# **************************************************************************** #
#                              PHONY TARGETS                                   #
# **************************************************************************** #

.PHONY: up down fclean re

# **************************************************************************** #
#                              COLOR SETTING                                   #
# **************************************************************************** #

COLOR_RESET = \033[0m
PINKB = \033[1;95m
REDB = \033[1;91m
ROSEB = \033[1;38;5;225m
BLUEB = \033[1;34m
BABEBLUEB = \033[1;38;5;153m
GREENB = \033[1;38;5;85m
PURPLEB = \033[1;38;5;55m
PSTL_YELLOWB = \033[1;38;2;255;253;208m
PSTL_ORGB = \033[1;38;2;255;179;102m
PSTL_PURPLEB =\033[1;38;2;204;153;255m

GREEN_BBG = \033[1;42m
BLUE_BBG = \033[1;44m
YELLOW_BBG = \033[1;43m
ORANGE_BBG = \033[1;48;5;214m


# make: create volumes and start the stack
# make up: shortcut to (1)Prepare your environment / (2)Build Docker images / (3)Launch WordPress + Nginx + MariaDB stack
# use make up when-> 
#(1)Have multiple targets (like make down, make re, make fclean)
#(2)Need to run one specific target instead of the default (all)
# make down: stop and clean up containers