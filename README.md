*This project has been created as part of the 42 curriculum by ntodisoa.*

# Inception

## Description

This project sets up a complete Docker infrastructure for hosting a WordPress website. The goal is to virtualize multiple interconnected services, each running in its own dedicated container.

The infrastructure includes:
- **NGINX**: Entry point configured with TLSv1.3 and self-signed SSL certificate
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

Below is an example `.env` content used by the stack. Adjust values as needed and keep this file private:

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

Add the domain to `/etc/hosts`:
```bash
echo "127.0.0.1 ntodisoa.42.fr" | sudo tee -a /etc/hosts
```

### Access

- Website: https://ntodisoa.42.fr
- Admin panel : https://ntodisoa.42.fr/wp-admin
- Admin: `your_admin_username` / `your_admin_password`
- Author: `your_author_username` / `your_author_password`

## Design Choices & Comparisons

### Virtual Machines vs Docker

**Choice**: Docker containers

**Justification**: Docker containers share the host kernel, making them significantly more lightweight and faster to start compared to full virtual machines. This approach reduces resource consumption while providing sufficient isolation for development and deployment environments.

**Comparison**:
- **Docker** (chosen): Lightweight, fast startup, minimal overhead, shares host kernel
- **Virtual Machines**: Full hardware virtualization, complete isolation, higher resource usage, slower initialization

---

### Secrets vs Environment Variables

**Choice**: Environment variables via `.env` file

**Justification**: All credentials and configuration values are centralized in a single `.env` file. This approach avoids hardcoding sensitive values directly in Dockerfiles or shell scripts, reducing the risk of accidentally committing secrets to version control.

**Comparison**:
- **Environment Variables** (chosen): Simple to manage, centralized configuration, compatible with Docker Compose, reduces code clutter
- **Secrets Management Tools** (Docker Secrets, HashiCorp Vault): More sophisticated but adds complexity not needed for this project scope

---

### Docker Network vs Host Network

**Choice**: Custom bridge network (`inception`)

**Justification**: A custom bridge network provides superior isolation and security. Containers communicate exclusively through defined network connections using service names as DNS, preventing unwanted exposure to the host network and limiting attack surface.

**Comparison**:
- **Custom Bridge Network** (chosen): Better isolation, service discovery via DNS, controlled communication, enhanced security
- **Host Network Mode**: Shared network stack with host, simpler but less isolation, potential port conflicts, security risks

---

### Docker Volumes vs Bind Mounts

**Choice**: Bind mounts to `/home/ntodisoa/data/mariadb` and `/home/ntodisoa/data/wordpress`

**Justification**: Bind mounts provide explicit control over persistence locations and allow direct file access from the host system. This enables easier data backup, inspection, and recovery without relying on Docker's internal storage abstraction.

**Comparison**:
- **Bind Mounts** (chosen): Direct host access, explicit location control, easier backup/inspection, better for development
- **Docker Volumes**: Managed by Docker, more portable, better for production, less direct host access

## Resources

### Documentation

- [Docker Documentation](https://docs.docker.com/get-started/)
- [Débuter de zéro avec Docker](https://www.youtube.com/playlist?list=PL8SZiccjllt1jz9DsD4MPYbbiGOR_FYHu)
- [Debian Bookworm](https://www.debian.org/releases/bookworm/)
- [WordPress CLI](https://wp-cli.org/)
- [How to Install Wordpress With Nginx on Debian 10 VPS](https://www.youtube.com/watch?v=0eQiiUZ66lE)
- [MySQL and MariaDB Tutorials](https://www.youtube.com/playlist?list=PLiHa1s-EL3vglMHsrjD2lQ6LfFWk7KHyF)
- [Nginx TLS Configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)

### AI Usage

**Tasks performed**:
- help with nginx configuration syntax (TLSv1.3)
- help with bash initialization scripts creation 
- Debugging permission and DNS resolution issues
- help with `docker-compose.yml` generation with volumes and network
- Help with redaction and translation of .md files in English and building a better Makefile

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
