# Inception Project

## Description

This project involves setting up a small infrastructure composed of different services under specific rules using Docker Compose. The infrastructure includes:

- **NGINX** with TLSv1.2/TLSv1.3 only (port 443)
- **WordPress** with php-fpm (no nginx)
- **MariaDB** (no nginx)
- **Volumes** for WordPress database and website files
- **Docker network** for container communication

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│    NGINX    │───▶│  WordPress  │───▶│   MariaDB   │
│   (HTTPS)   │    │  (PHP-FPM)  │    │ (Database)  │
└─────────────┘    └─────────────┘    └─────────────┘
      :443              :9000              :3306
```

## Requirements Met

✅ Docker Compose infrastructure  
✅ Each service in dedicated container  
✅ Built from Debian Bookworm Slim  
✅ Custom Dockerfiles (no pulling from DockerHub except base images)  
✅ NGINX with TLSv1.2/TLSv1.3 only  
✅ WordPress with PHP-FPM (no nginx)  
✅ MariaDB only (no nginx)  
✅ Persistent volumes for database and WordPress files  
✅ Docker network for container communication  
✅ Automatic restart on crash  
✅ No hacky patches (tail -f, sleep infinity, etc.)  
✅ Two WordPress users (admin without 'admin' in username)  
✅ Volumes mounted to /home/ntodisoa/data  
✅ Domain name ntodisoa.42.fr pointing to local IP  
✅ No passwords in Dockerfiles  
✅ Environment variables and secrets  
✅ NGINX as sole entry point on port 443  

## Setup Instructions

### 1. Add Domain to Hosts File
```bash
make add-host
```
Or manually add to `/etc/hosts`:
```
127.0.0.1 ntodisoa.42.fr
```

### 2. Build and Start Infrastructure
```bash
make all
```

### 3. Access the Website
Open your browser and go to: `https://ntodisoa.42.fr`

**Note**: You'll see a SSL warning (self-signed certificate) - this is expected.

## Available Commands

```bash
# Build and start everything
make all

# Build images only
make build

# Start services
make up

# Stop services
make down

# Clean containers and networks
make clean

# Full clean (remove everything)
make fclean

# Rebuild from scratch
make re

# View logs
make logs

# Check status
make status

# Individual services
make mariadb
make wordpress
make nginx

# Shell access
make mariadb-shell
make wordpress-shell
make nginx-shell

# Test database
make test-db
```

## WordPress Users

The setup creates two WordPress users:

1. **Administrator**: `ntodisoa` (site owner)
2. **Author**: `user42` (regular user)

Passwords are defined in the `.env` file.

## Data Persistence

Data is stored in:
- `/home/ntodisoa/data/mariadb` - Database files
- `/home/ntodisoa/data/wordpress` - WordPress files

## Security Features

- TLS 1.2/1.3 encryption
- No exposed database ports
- Internal docker network communication
- Security headers in NGINX
- No passwords in Dockerfiles
- Environment variable configuration

## Troubleshooting

1. **Port 443 already in use**: Stop any other web servers
2. **Permission denied on data folders**: Check folder permissions
3. **SSL certificate errors**: Expected for self-signed certificates
4. **Database connection errors**: Check if all containers are running with `make status`