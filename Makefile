# ================================= COLORS =================================== #
GREEN		= \033[0;92m
BOLD_GREEN	= \033[1;92m
CYAN		= \033[0;96m
YELLOW		= \033[0;93m
BLUE		= \033[0;34m
BOLD_BLUE	= \033[1;34m
BOLD_RED	= \033[1;31m
RESET		= \033[0m

# ================================= VARIABLES ================================ #
NAME		= inception
COMPOSE		= docker-compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_PATH	= /home/afodil-c/data

# ================================== RULES =================================== #

all: build up

build:
	@echo "$(CYAN)Building Docker images...$(RESET)"
	@$(COMPOSE) build
	@echo "$(BOLD_GREEN)Build complete!$(RESET)"

up:
	@echo "$(CYAN)Creating data directories...$(RESET)"
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	@echo "$(CYAN)Starting containers...$(RESET)"
	@$(COMPOSE) up -d
	@echo "$(BOLD_GREEN)All services started!$(RESET)"
	@echo "$(BLUE)Access: https://afodil-c.42.fr$(RESET)"

down:
	@echo "$(YELLOW)Stopping containers...$(RESET)"
	@$(COMPOSE) down
	@echo "$(YELLOW)Containers stopped.$(RESET)"

logs:
	@$(COMPOSE) logs -f

clean:
	@echo "$(YELLOW)Cleaning containers and volumes...$(RESET)"
	@$(COMPOSE) down --remove-orphans
	@echo "$(YELLOW)Clean complete.$(RESET)"

fclean: clean
	@echo "$(BOLD_RED)Removing Docker volumes...$(RESET)"
	@docker volume rm inception_mariadb_data inception_wordpress_data 2>/dev/null || true
	@echo "$(BOLD_RED)Removing all data...$(RESET)"
	@if [ -d "$(DATA_PATH)/mariadb" ] && [ "$$(ls -A $(DATA_PATH)/mariadb 2>/dev/null)" ]; then \
		docker run --rm -v $(DATA_PATH)/mariadb:/data alpine sh -c "rm -rf /data/* /data/.[!.]* 2>/dev/null || true"; \
	fi
	@if [ -d "$(DATA_PATH)/wordpress" ] && [ "$$(ls -A $(DATA_PATH)/wordpress 2>/dev/null)" ]; then \
		docker run --rm -v $(DATA_PATH)/wordpress:/data alpine sh -c "rm -rf /data/* /data/.[!.]* 2>/dev/null || true"; \
	fi
	@echo "$(BOLD_RED)Full clean complete.$(RESET)"

re: fclean all

.PHONY: all build up down logs clean fclean re
