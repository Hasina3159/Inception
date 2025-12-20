FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-xml \
        php8.2-mbstring \
        wget \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php && \
    sed -i 's/^error_log = .*/error_log = \/proc\/self\/fd\/2/' /etc/php/8.2/fpm/php-fpm.conf

# Télécharger WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp && \
    chmod +x /usr/local/bin/wp

# Copier configuration
COPY tools/init_wordpress.sh /usr/local/bin/init_wordpress.sh
COPY tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN chmod +x /usr/local/bin/init_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

CMD ["/usr/local/bin/init_wordpress.sh"]
