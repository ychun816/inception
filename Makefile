# **************************************************************************** #
#                                 DIRECTORIES                                  #
# **************************************************************************** #

#DATA_DIR : make variable , $(HOME) fetches current home's directory
DATA_DIR = $(HOME)/data
MARIADB_DATA = $(DATA_DIR)/mariadb_data/
WORDPRESS_DATA = $(DATA_DIR)/wordpress_data/

#BONUS
REDIS_DATA = $(DATA_DIR)/redis_data/
ADMINER_DATA = $(DATA_DIR)/adminer_data/

# **************************************************************************** #
#                              SRC & OBJ FILES                                 #
# **************************************************************************** #

COMPOSE_FL = ./srcs/docker-compose.yml

# **************************************************************************** #
#                               BUILD COMMANDS                                 #
# **************************************************************************** #

### BUILD TARGETS ###

all: up

up:
	mkdir -p $(DATA_DIR)
	mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA) 
	mkdir -p $(REDIS_DATA) $(ADMINER_DATA)
	docker compose -f $(COMPOSE_FL) up -d --build

checkenv:
	@if [ -f srcs/.env ]; then \
		echo "$(GREENB)✅ .env file already exists$(COLOR_RESET)"; \
	else \
		echo "$(BLUEB)⚠️ .env file not found$(COLOR_RESET)"; \
		read -p "Enter path to .env file: " env_path; \
		if [ -f "$$env_path" ]; then \
			cp "$$env_path" srcs/.env; \
			echo "$(GREENB)✅ .env file copied successfully$(COLOR_RESET)"; \
		else \
			echo "$(REDB)❌ .env file not found at $$env_path$(COLOR_RESET)"; \
			exit 1; \
		fi; \
	fi

status:
	$(STATUS_CHECK_TABLE)

supertest:
	@echo "$(BLUEB)🧪 Running comprehensive tests...$(COLOR_RESET)"
	@chmod +x ./supertest_inception.sh
	@./supertest_inception.sh


### CLEANUP ###

down:
	docker compose -f $(COMPOSE_FL) down

fclean:
	./cleanup.sh
	@echo "$(BABEBLUEB)🫧 FULL CLEANUP DONE! 🫧$(COLOR_RESET)"


### REBUILD ###

re: fclean
	$(MAKE) up
	@echo "$(REDB)RE DONE$(COLOR_RESET)"

# **************************************************************************** #
#                              PHONY TARGETS                                   #
# **************************************************************************** #

.PHONY: up getenv status test down fclean re 

# **************************************************************************** #
#                           HELPER: CHECK SCRIPT                               #
# **************************************************************************** #

# Status check commands
define STATUS_CHECK_TABLE
	@echo "$(BLUEB)📊 SYSTEM STATUS:$(COLOR_RESET)"
	@echo "$(PINKB)Containers:$(COLOR_RESET)"
	@docker compose -f $(COMPOSE_FL) ps
	@echo "$(PINKB)Networks:$(COLOR_RESET)"
	@docker network ls
	@echo "$(PINKB)Data directories:$(COLOR_RESET)"
	@ls -la $(DATA_DIR) 2>/dev/null || echo "Data directory not found"
	@echo "$(PINKB)Website status:$(COLOR_RESET)"
	@curl -k -s -I https://yilin.42.fr | head -1 || echo "Website not accessible"
endef

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

# **************************************************************************** #
#                                    NOTES                                     #
# **************************************************************************** #

# $(MAKE): built-in variable for portable make invocation
# mkdir -p: creates directories if they don't exist (-p avoids errors) -> better practice
# docker compose -f: specifies the compose file
# up -d --build: starts services in detached mode and rebuilds images