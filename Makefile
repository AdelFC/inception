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
LOGIN		= afodil-c
COMPOSE		= docker-compose -f srcs/docker-compose.yml --env-file srcs/.env
DATA_PATH	= /home/$(LOGIN)/data

# ================================== RULES =================================== #

all: env build up

env:
	@if [ ! -f "srcs/.env" ]; then \
		echo "$(YELLOW)Creating .env...$(RESET)"; \
		echo "DB_NAME=wordpress" > srcs/.env; \
		echo "DB_ADMIN_NAME=$(LOGIN)" >> srcs/.env; \
		echo "DOMAIN=$(LOGIN).42.fr" >> srcs/.env; \
		echo "WP_TITLE=Inception" >> srcs/.env; \
		echo "WP_ADMIN_NAME=$(LOGIN)" >> srcs/.env; \
		echo "WP_ADMIN_EMAIL=$(LOGIN)@student.42.fr" >> srcs/.env; \
		echo "WP_USER_NAME=user42" >> srcs/.env; \
		echo "WP_USER_EMAIL=user42@student.42.fr" >> srcs/.env; \
		echo "$(BOLD_GREEN).env created!$(RESET)"; \
	else \
		echo "$(GREEN).env already exists$(RESET)"; \
	fi
	@if [ ! -d "secrets" ]; then \
		echo "$(YELLOW)Creating secrets...$(RESET)"; \
		mkdir -p secrets; \
		read -p "Database password: " db_pass; echo "$$db_pass" > secrets/db_password.txt; \
		read -p "Database root password: " db_root_pass; echo "$$db_root_pass" > secrets/db_root_password.txt; \
		read -p "WordPress admin password: " wp_admin_pass; echo "$$wp_admin_pass" > secrets/wp_admin_password.txt; \
		read -p "WordPress user password: " wp_user_pass; echo "$$wp_user_pass" > secrets/wp_user_password.txt; \
		echo "$(BOLD_GREEN)Secrets created!$(RESET)"; \
	else \
		echo "$(GREEN)Secrets already exist$(RESET)"; \
	fi

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
	@echo "$(BLUE)Access: https://$(LOGIN).42.fr$(RESET)"

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
	@docker volume rm mariadb wordpress 2>/dev/null || true
	@echo "$(BOLD_RED)Removing all data...$(RESET)"
	@if [ -d "$(DATA_PATH)/mariadb" ] && [ "$$(ls -A $(DATA_PATH)/mariadb 2>/dev/null)" ]; then \
		docker run --rm -v $(DATA_PATH)/mariadb:/data alpine sh -c "rm -rf /data/* /data/.[!.]* 2>/dev/null || true"; \
	fi
	@if [ -d "$(DATA_PATH)/wordpress" ] && [ "$$(ls -A $(DATA_PATH)/wordpress 2>/dev/null)" ]; then \
		docker run --rm -v $(DATA_PATH)/wordpress:/data alpine sh -c "rm -rf /data/* /data/.[!.]* 2>/dev/null || true"; \
	fi
	@rm -rf secrets srcs/.env
	@echo "$(BOLD_RED)Full clean complete.$(RESET)"

re: fclean all

.PHONY: all env build up down logs clean fclean re
