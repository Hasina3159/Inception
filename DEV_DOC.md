# Developer Documentation

## Set Up Environment from Scratch

### Prerequisites

- Linux OS
- Docker (version 20.10+)
- Docker Compose (version 2.0+)
- Make

### Configuration Files

1. Clone repository:
```bash
git clone <inception-repository-url>
cd Inception
```

2. Create and configure `.env` file like below with all required credentials :
```dotenv
# MariaDB Configuration
MARIADB_DATABASE=wordpress
MARIADB_USER=wp_user
MARIADB_PASSWORD=wppassword123
MARIADB_ROOT_PASSWORD=rootpassword.123

# WordPress Database Connection
WORDPRESS_DB_HOST=mariadb
WORDPRESS_DB_NAME=wordpress
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_PASSWORD=wppassword.123
WORDPRESS_TABLE_PREFIX=wp_

# WordPress Site Configuration
WORDPRESS_URL=https://ntodisoa.42.fr
WORDPRESS_TITLE=Inception_petera

# WordPress Admin Account (can approve comments, manage site)
WORDPRESS_SITE_OWNER=petera
WORDPRESS_SITE_OWNER_PASSWORD=petera.123
WORDPRESS_SITE_OWNER_EMAIL=petera@petera.42.fr

# WordPress Author Account (can write posts but NOT approve comments)
WORDPRESS_USER=mpamorona
WORDPRESS_USER_EMAIL=mpamorona@mpamorona.42.fr
WORDPRESS_USER_PASSWORD=mpamorona.123
```

3. Configure domain:
```bash
echo "127.0.0.1 ntodisoa.42.fr" | sudo tee -a /etc/hosts
```

## Build and Launch with Makefile and Docker Compose

### Using Makefile

```bash
make        # Build and start
make build  # Build images only
make up     # Start containers
make down   # Stop containers
make fclean # Remove everything
make re     # Rebuild all
```

### Using Docker Compose

```bash
cd srcs
docker compose build
docker compose up -d
docker compose down
```

## Manage Containers and Volumes

### Container Management

```bash
# View containers
docker compose -f srcs/docker-compose.yml ps

# Execute commands
docker exec -it mariadb bash
docker exec -it wordpress bash
docker exec -it nginx bash

# View logs
docker logs mariadb
docker logs wordpress
docker logs nginx

# Restart service
docker restart mariadb
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data

# Access data directly (bind mounts)
ls -la /home/ntodisoa/data/mariadb/
ls -la /home/ntodisoa/data/wordpress/
```

## Data Storage and Persistence

### Storage Locations

- **MariaDB data**: `/home/ntodisoa/data/mariadb/` (bind mount from `/var/lib/mysql`)
- **WordPress files**: `/home/ntodisoa/data/wordpress/` (bind mount from `/var/www/html`)

### How Data Persists

Data is stored on the host filesystem using bind mounts:
- Survives container restarts
- Survives container rebuilds
- Accessible directly from host

### Verify Persistence

1. Create WordPress content
2. Run `make down`
3. Run `make up`
4. Content still exists
