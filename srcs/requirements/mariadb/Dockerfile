FROM debian:bookworm-slim

# Default envs (can be overridden at runtime)
ENV MARIADB_DATABASE=wordpress \
	MARIADB_USER=wp_user \
	MARIADB_PASSWORD=wp_pass \
	MARIADB_ROOT_PASSWORD=supersecret \
	MARIADB_DATA_DIR=/var/lib/mysql

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		mariadb-server \
		gosu \
		ca-certificates \
		curl \
		tzdata; \
	rm -rf /var/lib/apt/lists/*; \
	mkdir -p ${MARIADB_DATA_DIR} /run/mysqld; \
	chown -R mysql:mysql ${MARIADB_DATA_DIR} /run/mysqld

# Copy config and tools
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init_db.sh /usr/local/bin/init_db.sh

RUN chmod +x /usr/local/bin/init_db.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
  CMD mariadb-admin ping -h 127.0.0.1 || exit 1

ENTRYPOINT ["/usr/local/bin/init_db.sh"]

