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
git clone git@github.com:Hasina3159/Inception.git
cd Inception
```

2. Create `.env` from template:
```bash
cp .env.example .env
```

3. Configure domain:
```bash
echo "127.0.0.1 ntodisoa.42.fr" | sudo tee -a /etc/hosts
```

4. Create data directories:
```bash
mkdir -p /home/mira/data/wordpress /home/mira/data/mariadb
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
ls -la /home/mira/data/mariadb/
ls -la /home/mira/data/wordpress/
```

## Data Storage and Persistence

### Storage Locations

- **MariaDB data**: `/home/mira/data/mariadb/` (bind mount from `/var/lib/mysql`)
- **WordPress files**: `/home/mira/data/wordpress/` (bind mount from `/var/www/html`)

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
