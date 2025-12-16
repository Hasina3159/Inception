FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-curl \
        php8.2-gd \
        php8.2-xml \
        php8.2-mbstring \
        curl && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/www/html /run/php && \
    chown -R www-data:www-data /var/www/html /run/php

# Télécharger WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v2.8.1/php/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copier configuration
COPY tools/init_wordpress.sh /usr/local/bin/init_wordpress.sh
COPY tools/www.conf /etc/php/8.2/fpm/pool.d/www.conf
RUN chmod +x /usr/local/bin/init_wordpress.sh

WORKDIR /var/www/html

EXPOSE 9000

USER www-data

CMD ["/usr/local/bin/init_wordpress.sh"]
