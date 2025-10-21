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
COMPOSE		= docker compose -f srcs/docker-compose.yml --env-file .env
DATA_PATH	= /home/afc/data

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

ps:
	@$(COMPOSE) ps

clean:
	@echo "$(YELLOW)Cleaning containers and volumes...$(RESET)"
	@$(COMPOSE) down -v --remove-orphans
	@echo "$(YELLOW)Clean complete.$(RESET)"

fclean: clean
	@echo "$(BOLD_RED)Removing all data...$(RESET)"
	@sudo rm -rf $(DATA_PATH)/mariadb/* $(DATA_PATH)/wordpress/*
	@echo "$(BOLD_RED)Full clean complete.$(RESET)"

re: fclean all

.PHONY: all build up down logs ps clean fclean re
