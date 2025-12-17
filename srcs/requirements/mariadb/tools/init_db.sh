#!/usr/bin/env bash
set -euo pipefail

: "${MARIADB_DATABASE:=wordpress}"
: "${MARIADB_USER:=wp_user}"
: "${MARIADB_PASSWORD:?MARIADB_PASSWORD required}"
: "${MARIADB_ROOT_PASSWORD:?MARIADB_ROOT_PASSWORD required}"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Initialize if mysql system DB doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[INIT] Initializing MariaDB system database"
  chown -R mysql:mysql /var/lib/mysql
  mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

# Check if wordpress database exists
if [ ! -d "/var/lib/mysql/$MARIADB_DATABASE" ]; then
  echo "[INIT] Database '$MARIADB_DATABASE' not found, running setup"
  
  mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid=$!

  for i in {1..30}; do
    mariadb-admin --socket=/run/mysqld/mysqld.sock ping &>/dev/null && break
    sleep 1
  done

  echo "[INIT] Securing and creating database/user"
  mariadb --socket=/run/mysqld/mysqld.sock <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  echo "[INIT] Shutting down bootstrap server"
  mariadb-admin --socket=/run/mysqld/mysqld.sock shutdown
  wait "$pid"
  echo "[INIT] Initialization complete"
fi

echo "[MAIN] Starting MariaDB server"
exec mysqld --user=mysql --bind-address=0.0.0.0
