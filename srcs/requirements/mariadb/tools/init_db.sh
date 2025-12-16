#!/usr/bin/env bash
set -euo pipefail

: "${MARIADB_DATABASE:=wordpress}"
: "${MARIADB_USER:=wp_user}"
: "${MARIADB_PASSWORD:=}"
: "${MARIADB_ROOT_PASSWORD:=}"

read_secret() {
  for dir in "/run/secrets" "/secrets"; do
    [ -r "$dir/$1" ] && cat "$dir/$1" && return 0
  done
  return 1
}

[ -z "$MARIADB_ROOT_PASSWORD" ] && MARIADB_ROOT_PASSWORD="$(read_secret db_root_password.txt || true)"
[ -z "$MARIADB_PASSWORD" ] && MARIADB_PASSWORD="$(read_secret db_password.txt || true)"

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ -z "$(ls -A /var/lib/mysql 2>/dev/null || true)" ]; then
  chown -R mysql:mysql /var/lib/mysql
  mysql_install_db --user=mysql --datadir=/var/lib/mysql

  mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
  pid=$!

  for i in {1..30}; do
    mariadb-admin --socket=/run/mysqld/mysqld.sock ping &>/dev/null && break
    sleep 1
  done

  [ -z "$MARIADB_ROOT_PASSWORD" ] && echo "ERROR: MARIADB_ROOT_PASSWORD required" >&2 && exit 1
  [ -z "$MARIADB_PASSWORD" ] && echo "ERROR: MARIADB_PASSWORD required" >&2 && exit 1

  mariadb --socket=/run/mysqld/mysqld.sock <<-SQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
    DELETE FROM mysql.user WHERE User='';
    DROP DATABASE IF EXISTS test;
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;
SQL

  mariadb-admin --socket=/run/mysqld/mysqld.sock shutdown
  wait "$pid"
fi

exec mysqld --user=mysql --bind-address=0.0.0.0
