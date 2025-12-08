# Inception Project Makefile

.PHONY: all build up down clean fclean re logs status setup-volumes

# Variables
DATA_DIR = /home/ntodisoa/data
MARIADB_DATA_DIR = $(DATA_DIR)/mariadb
WORDPRESS_DATA_DIR = $(DATA_DIR)/wordpress

# Default target
all: setup-volumes build up

# Create data directories on host
setup-volumes:
	@echo "Creating data directories..."
	@mkdir -p $(MARIADB_DATA_DIR)
	@mkdir -p $(WORDPRESS_DATA_DIR)
	@echo "Data directories created successfully"

# Build all images
build:
	@echo "Building Docker images..."
	cd srcs && docker compose build --no-cache

# Start the services
up:
	@echo "Starting services..."
	cd srcs && docker compose up -d

# Stop the services
down:
	@echo "Stopping services..."
	cd srcs && docker compose down

# Clean containers and networks
clean: down
	@echo "Cleaning containers and networks..."
	cd srcs && docker compose down --volumes --remove-orphans
	docker system prune -f

# Full clean (including images and volumes)
fclean: clean
	@echo "Full clean - removing images and data..."
	docker image rm -f mariadb:inception wordpress:inception nginx:inception 2>/dev/null || true
	docker system prune -af --volumes
	sudo rm -rf $(DATA_DIR)

# Rebuild everything
re: fclean all

# Show logs
logs:
	cd srcs && docker compose logs -f

# Show services status
status:
	cd srcs && docker compose ps

# Individual service targets
mariadb: setup-volumes
	cd srcs && docker compose build mariadb
	cd srcs && docker compose up -d mariadb

wordpress: mariadb
	cd srcs && docker compose build wordpress
	cd srcs && docker compose up -d wordpress

nginx: wordpress
	cd srcs && docker compose build nginx
	cd srcs && docker compose up -d nginx

# Shell access
mariadb-shell:
	docker exec -it mariadb bash

wordpress-shell:
	docker exec -it wordpress bash

nginx-shell:
	docker exec -it nginx bash

# Test database connection
test-db:
	docker exec mariadb mariadb -u root -p -e "SHOW DATABASES;"

# Add host entry for domain
add-host:
	@echo "Adding ntodisoa.42.fr to /etc/hosts..."
	@echo "127.0.0.1 ntodisoa.42.fr" | sudo tee -a /etc/hosts

# Remove host entry
remove-host:
	@echo "Removing ntodisoa.42.fr from /etc/hosts..."
	@sudo sed -i '/ntodisoa.42.fr/d' /etc/hosts
