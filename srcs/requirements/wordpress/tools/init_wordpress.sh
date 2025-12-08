#!/bin/bash
set -euo pipefail

echo "Starting WordPress initialization..."

# Function to wait for database
wait_for_db() {
    echo "Waiting for database connection..."
    until php -r "
        try {
            \$pdo = new PDO('mysql:host=${WORDPRESS_DB_HOST};dbname=${WORDPRESS_DB_NAME}', '${WORDPRESS_DB_USER}', '${WORDPRESS_DB_PASSWORD}');
            echo 'Database connection successful' . PHP_EOL;
            exit(0);
        } catch (PDOException \$e) {
            echo 'Database connection failed: ' . \$e->getMessage() . PHP_EOL;
            exit(1);
        }
    "; do
        echo "Database not ready yet, waiting 5 seconds..."
        sleep 5
    done
}

# Wait for database to be ready
wait_for_db

# Download WordPress if not already present
if [ ! -f /var/www/html/wp-config.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root --path=/var/www/html
    
    echo "Creating wp-config.php..."
    wp config create \
        --dbname="${WORDPRESS_DB_NAME}" \
        --dbuser="${WORDPRESS_DB_USER}" \
        --dbpass="${WORDPRESS_DB_PASSWORD}" \
        --dbhost="${WORDPRESS_DB_HOST}" \
        --dbprefix="${WORDPRESS_TABLE_PREFIX}" \
        --allow-root \
        --path=/var/www/html
    
    # Check if WordPress is already installed
    if ! wp core is-installed --allow-root --path=/var/www/html 2>/dev/null; then
        echo "Installing WordPress..."
        wp core install \
            --url="${WORDPRESS_URL}" \
            --title="${WORDPRESS_TITLE}" \
            --admin_user="${WORDPRESS_SITE_OWNER}" \
            --admin_password="${WORDPRESS_SITE_OWNER_PASSWORD}" \
            --admin_email="${WORDPRESS_SITE_OWNER_EMAIL}" \
            --allow-root \
            --path=/var/www/html
        
        echo "Creating additional user..."
        wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" \
            --user_pass="${WORDPRESS_USER_PASSWORD}" \
            --role=author \
            --allow-root \
            --path=/var/www/html
        
        echo "WordPress installation completed with two users!"
    else
        echo "WordPress is already installed."
    fi
else
    echo "WordPress configuration already exists."
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

echo "Starting PHP-FPM..."
exec php-fpm8.2 --nodaemonize
