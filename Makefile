.PHONY: all build up down clean fclean re logs status setup-volumes

DATA_DIR = /home/mira/data
MARIADB_DATA_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DATA_DIR = $(DATA_DIR)/wordpress

all: setup-volumes build up

setup-volumes:
	@echo "Creating data directories..."
	@mkdir -p $(MARIADB_DATA_DIR)
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@echo "Data directories created successfully"

build:
	@echo "Building Docker images..."
	cd srcs && docker compose build --no-cache

up:
	@echo "Starting services..."
	cd srcs && docker compose up -d

down:
	@echo "Stopping services..."
	cd srcs && docker compose down

clean: down
	@echo "Cleaning containers and networks..."
	cd srcs && docker compose down --volumes --remove-orphans
	docker system prune -f

fclean: clean
	@echo "Full clean - removing images and data..."
	docker image rm -f mariadb:inception wordpress:inception nginx:inception 2>/dev/null || true
	docker system prune -af --volumes
	sudo rm -rf $(DATA_DIR)

re: fclean all

logs:
	cd srcs && docker compose logs -f

status:
	cd srcs && docker compose ps

mariadb: setup-volumes
	cd srcs && docker compose build mariadb
	cd srcs && docker compose up -d mariadb

wordpress: mariadb
	cd srcs && docker compose build wordpress
	cd srcs && docker compose up -d wordpress

nginx: wordpress
	cd srcs && docker compose build nginx
	cd srcs && docker compose up -d nginx

mariadb-shell:
	docker exec -it mariadb bash

wordpress-shell:
	docker exec -it wordpress bash

nginx-shell:
	docker exec -it nginx bash

test-db:
	docker exec mariadb mariadb -u root -p -e "SHOW DATABASES;"

add-host:
	@echo "Adding ntodisoa.42.fr to /etc/hosts..."
	@echo "127.0.0.1 ntodisoa.42.fr" | sudo tee -a /etc/hosts

remove-host:
	@echo "Removing ntodisoa.42.fr from /etc/hosts..."
	@sudo sed -i '/ntodisoa.42.fr/d' /etc/hosts
