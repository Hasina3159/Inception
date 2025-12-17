# User Documentation

## Services Provided

The Inception stack provides:

- **WordPress Website**: Content management system accessible via HTTPS
- **MariaDB Database**: Database backend for WordPress
- **Nginx Web Server**: Reverse proxy with TLS encryption (TLSv1.3)

## Start and Stop the Project

### Start

```bash
make
```

### Stop

```bash
make down
```

### Complete cleanup

```bash
make fclean
```

## Access the Website and Administration Panel

### Website Access

- URL: https://ntodisoa.42.fr
- Accept the self-signed certificate warning

### Administration Panel

- Admin URL: https://ntodisoa.42.fr/wp-admin
- Admin username: `admin`
- Admin password: `petera123`

### User Accounts

- **Administrator**: `admin` / `petera123` (can approve comments)
- **Author**: `author` / `lambda123` (can write posts only)

## Locate and Manage Credentials

### Location

All credentials are in the `.env` file at the project root.

### Credentials Table

| Service | Username | Password Variable | Default Value |
|---------|----------|-------------------|---------------|
| MariaDB Root | root | `MARIADB_ROOT_PASSWORD` | rootpassword123 |
| MariaDB User | wp_user | `MARIADB_PASSWORD` | wppassword123 |
| WordPress Admin | admin | `WORDPRESS_SITE_OWNER_PASSWORD` | petera123 |
| WordPress Author | author | `WORDPRESS_USER_PASSWORD` | lambda123 |

### Change Credentials

1. Edit `.env`
2. Run `make re`

## Check Services Status

### View running containers

```bash
docker compose -f srcs/docker-compose.yml ps
```

### View logs

```bash
docker compose -f srcs/docker-compose.yml logs
```

### Check specific service

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```
