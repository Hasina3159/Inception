#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by ENV)
: "${MARIADB_DATABASE:=wordpress}"
: "${MARIADB_USER:=wp_user}"
: "${MARIADB_PASSWORD:=}"
: "${MARIADB_ROOT_PASSWORD:=}"
: "${MARIADB_DATA_DIR:=/var/lib/mysql}"

# Optional secrets paths
SECRETS_DIR_PRIMARY="/run/secrets"
SECRETS_DIR_ALT="/secrets"

read_secret() {
  local name="$1"; shift || true
  for dir in "$SECRETS_DIR_PRIMARY" "$SECRETS_DIR_ALT"; do
    if [ -r "$dir/$name" ]; then
      cat "$dir/$name"
      return 0
    fi
  done
  return 1
}

# Load secrets if present, fallback to env
if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
  MARIADB_ROOT_PASSWORD="$(read_secret db_root_password.txt || true)"
fi
if [ -z "$MARIADB_PASSWORD" ]; then
  MARIADB_PASSWORD="$(read_secret db_password.txt || true)"
fi
if [ -z "$MARIADB_USER" ] || [ "$MARIADB_USER" = "wp_user" ]; then
  MARIADB_USER_CONTENT="$(read_secret credentials.txt || true)"
  if [ -n "$MARIADB_USER_CONTENT" ]; then
    # Expect format: username:password
    MARIADB_USER="$(printf "%s" "$MARIADB_USER_CONTENT" | cut -d: -f1)"
    if [ -z "$MARIADB_PASSWORD" ]; then
      MARIADB_PASSWORD="$(printf "%s" "$MARIADB_USER_CONTENT" | cut -d: -f2-)"
    fi
  fi
fi

# Ensure runtime dir
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize if empty
if [ -z "$(ls -A "$MARIADB_DATA_DIR" 2>/dev/null || true)" ]; then
  echo "[init] Initializing MariaDB data directory at $MARIADB_DATA_DIR"
  chown -R mysql:mysql "$MARIADB_DATA_DIR"
  gosu mysql mysqld --initialize-insecure --datadir="$MARIADB_DATA_DIR"

  echo "[init] Starting mysqld in background to run bootstrap SQL"
  gosu mysql mysqld --datadir="$MARIADB_DATA_DIR" --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid=$!

  # Wait for socket
  for i in {1..60}; do
    if mariadb-admin --socket=/run/mysqld/mysqld.sock ping &>/dev/null; then
      break
    fi
    sleep 1
  done

  echo "[init] Securing root account and creating database/user"
  if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "[init] ERROR: MARIADB_ROOT_PASSWORD not set and db_root_password.txt secret missing" >&2
    exit 1
  fi
  if [ -z "$MARIADB_PASSWORD" ]; then
    echo "[init] ERROR: MARIADB_PASSWORD not set and db_password.txt/credentials.txt secret missing" >&2
    exit 1
  fi

  mariadb --protocol=SOCKET --socket=/run/mysqld/mysqld.sock <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='' OR Host NOT IN ('localhost');
    DROP DATABASE IF EXISTS test;
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  echo "[init] Shutting down bootstrap mysqld"
  mariadb-admin --socket=/run/mysqld/mysqld.sock shutdown
  wait "$pid" || true
fi

# Exec server
exec gosu mysql mysqld --datadir="$MARIADB_DATA_DIR" --user=mysql --bind-address=0.0.0.0
