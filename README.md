*This project has been created as part of the 42 curriculum by ntodisoa.*

# Inception

## Description

This project sets up a complete Docker infrastructure for hosting a WordPress website. The goal is to virtualize multiple interconnected services, each runing in its own dedicated container.

The infrastructure includes:
- **NGINX**: Entry point configurated with TLSv1.3 and self-signed SSL certificate
- **WordPress + php-fpm**: Installed and configured with WP-CLI, including admin and author users
- **MariaDB**: Database for WordPress, automatically initialized

## Instructions

### Compilation and Execution

All configuration files are in the `srcs/` folder. The project is managed by a Makefile at the root:

```bash
make        # Build and start infrastructure
make down   # Stop services
make fclean # Complete cleanup (removes everything)
make re     # Rebuild all
```

### Configuration

Copy and edit the `.env` file:
```bash
cp .env.example .env
```

Add the domain to `/etc/hosts`:
```bash
echo "127.0.0.1 ntodisoa.42.fr" | sudo tee -a /etc/hosts
```

### Access

- Website: https://ntodisoa.42.fr
- Admin: `admin` / `petera123`
- Author: `author` / `lambda123`

## Design Choices & Comparisons

### Virtual Machines vs Docker

Docker containers share the host kernel for better efficiency, while VMs virtualize complete hardware. Containers are more lighter and start faster.

### Secrets vs Environment Variables

This project uses environment variables via a `.env` file for simplicity. All credentials are centralized in one file, avoiding hardcoded values in Dockerfiles or scripts.

### Docker Network vs Host Network

Using `network: host` is forbidden. An isolated bridge network (`inception`) ensures that only necessary services communicate via their service names.

### Docker Volumes vs Bind Mounts

Bind mounts to `/home/mira/data/mariadb` and `/home/mira/data/wordpress` allows explicit persistence and direct access to files from the host.

## Resources

### Documentation

- [Docker Documentation](https://docs.docker.com/)
- [Debian Bookworm](https://www.debian.org/releases/bookworm/)
- [WordPress CLI](https://wp-cli.org/)
- [MariaDB Documentation](https://mariadb.org/documentation/)
- [Nginx TLS Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)

### AI Usage

**Tasks performed**:
- help with nginx configuration syntax (TLSv1.3)
- help with bash initialization scripts creation (`init_db.sh`, `init_wordpress.sh`)
- Debugging permission and DNS resolution issues
- help with `docker-compose.yml` generation with volumes and network
- help with redaction and traduction of .md files in english and building a better makefile

**Project parts concerned**:
- NGINX configuration with TLSv1.3 and self-signed certificate
- MariaDB entry scripts with automatic database initialization
- WordPress script with WP-CLI for installation and user creation
- PHP-FPM (www.conf) and MariaDB (server.cnf) configurations
- Makefile for build and clean automation
- Network issues resolution (DNS Docker, service connectivity)

**Verification**:
Each code segment has been:
- Tested in real conditions with `docker compose up`
- Debugged via Docker logs (`docker compose logs`)
- Reviewed and adapted to 42 project constraints
- Functionally validated (HTTPS connection, WordPress posts, comment moderation)

The complete logic of the infrastructure (Docker network, volumes, init scripts, SSL certificates) is fully understood and mastered by the author.
