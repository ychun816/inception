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
#CLEANUP = ./cleanup.sh

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
#                           OTHER CHECK SCRIPT                                 #
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

# make: create volumes and start the stack
# make up: build and start the complete Docker stack
# make test: run comprehensive tests via test_inception.sh script
# make test-quick: run basic connectivity and service tests only
# make test-thorough: run comprehensive tests + additional detailed checks
# make down: stop and clean up containers
# make status: show current system status
# make logs: show recent logs from all containers
# make getenv: copy .env file if it doesn't exist

# $(MAKE): built-in variable for portable make invocation
# mkdir -p: creates directories if they don't exist (-p avoids errors)
# docker compose -f: specifies the compose file
# up -d --build: starts services in detached mode and rebuilds images


# **************************************************************************** #
#                                    EXTRA TESTING CMD                         #
# **************************************************************************** #

# test: 
# 	@echo "$(BLUEB)🧪 Running comprehensive tests...$(COLOR_RESET)"
# 	@chmod +x ./test_inception.sh
# 	@./test_inception.sh

# test-quick: test-containers test-connectivity test-wordpress
# 	@echo "$(GREENB)🎉 QUICK TESTS PASSED! 🎉$(COLOR_RESET)"

# test-thorough: test
# 	@echo "$(PURPLEB)🔍 Running additional thorough checks...$(COLOR_RESET)"
# 	@echo "$(BLUEB)Checking SSL certificate details:$(COLOR_RESET)"
# 	@echo | openssl s_client -connect yilin.42.fr:443 -servername yilin.42.fr 2>/dev/null | openssl x509 -noout -text 2>/dev/null | grep -E "(Subject:|Issuer:|Not After)" || true
# 	@echo "$(BLUEB)Checking WordPress plugins and themes:$(COLOR_RESET)"
# 	@docker exec wordpress wp plugin list --allow-root 2>/dev/null || true
# 	@docker exec wordpress wp theme list --allow-root 2>/dev/null || true
# 	@echo "$(GREENB)✅ THOROUGH TESTS COMPLETED!$(COLOR_RESET)"

# test-containers:
# 	@echo "$(BLUEB)📋 Testing container status...$(COLOR_RESET)"
# 	@docker compose -f $(COMPOSE_FL) ps | grep "Up" || (echo "$(REDB)❌ Some containers are not running$(COLOR_RESET)" && exit 1)
# 	@echo "$(GREENB)✅ All containers are running!$(COLOR_RESET)"

# test-connectivity:
# 	@echo "$(BLUEB)🌐 Testing HTTPS connectivity...$(COLOR_RESET)"
# 	@curl -k -s -f https://yilin.42.fr > /dev/null || (echo "$(REDB)❌ Website not accessible$(COLOR_RESET)" && exit 1)
# 	@echo "$(GREENB)✅ HTTPS connectivity working!$(COLOR_RESET)"

# test-wordpress:
# 	@echo "$(BLUEB)📝 Testing WordPress functionality...$(COLOR_RESET)"
# 	@docker exec wordpress wp --version --allow-root > /dev/null || (echo "$(REDB)❌ WP-CLI not working$(COLOR_RESET)" && exit 1)
# 	@echo "$(GREENB)✅ WordPress is functional!$(COLOR_RESET)"

# test-database:
# 	@echo "$(BLUEB)🗄️ Testing database connection...$(COLOR_RESET)"
# 	@docker exec mariadb mysql -u yilin -phappybirthday -e "SHOW DATABASES;" > /dev/null || (echo "$(REDB)❌ Database connection failed$(COLOR_RESET)" && exit 1)
# 	@echo "$(GREENB)✅ Database connection working!$(COLOR_RESET)"

# logs:
# 	@echo "$(BLUEB)📋 Container logs:$(COLOR_RESET)"
# 	docker compose -f $(COMPOSE_FL) logs --tail=20

# logs-nginx:
# 	@echo "$(BLUEB)🌐 Nginx logs:$(COLOR_RESET)"
# 	docker logs nginx --tail=30

# logs-wordpress:
# 	@echo "$(BLUEB)📝 WordPress logs:$(COLOR_RESET)"
# 	docker logs wordpress --tail=30

# logs-mariadb:
# 	@echo "$(BLUEB)🗄️ MariaDB logs:$(COLOR_RESET)"
# 	docker logs mariadb --tail=30

# status:
# 	@echo "$(BLUEB)📊 System Status:$(COLOR_RESET)"
# 	@echo "$(PINKB)Containers:$(COLOR_RESET)"
# 	@docker compose -f $(COMPOSE_FL) ps
# 	@echo "$(PINKB)Data directories:$(COLOR_RESET)"
# 	@ls -la $(DATA_DIR) 2>/dev/null || echo "Data directory not found"
# 	@echo "$(PINKB)Website status:$(COLOR_RESET)"
# 	@curl -k -s -I https://yilin.42.fr | head -1 || echo "Website not accessible"

# open:
# 	@echo "$(BLUEB)🌍 Opening website...$(COLOR_RESET)"
# 	@command -v chromium >/dev/null && chromium https://yilin.42.fr & || \
# 	 command -v firefox >/dev/null && firefox https://yilin.42.fr & || \
# 	 echo "$(REDB)No browser found. Open https://yilin.42.fr manually$(COLOR_RESET)"