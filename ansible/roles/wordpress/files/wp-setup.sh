#!/bin/bash
set -e
export WP_CLI_PHP_ARGS='-d memory_limit=512M'

echo "==== ENV DUMP ===="
env | grep -E 'MYSQL_|ADMIN_|WORDPRESS_'
echo "==================="

echo "Waiting for database..."
until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
  echo "Database not ready yet..."
  sleep 3
done

# Download WordPress if not present
if [ ! -f /var/www/html/wp-load.php ]; then
  echo "Downloading WordPress core..."
  wp core download --allow-root --path=/var/www/html
fi

cd /var/www/html

# Create config if missing
if [ ! -f wp-config.php ]; then
  echo "Creating wp-config.php..."
  wp config create \
    --dbname="$MYSQL_DATABASE" \
    --dbuser="$MYSQL_USER" \
    --dbpass="$MYSQL_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root; then
  echo "Installing WordPress..."
  wp core install \
    --url="https://ampik.duckdns.org" \
    --title="ampik-1" \
    --admin_user="${ADMIN_USER}" \
    --admin_password="${ADMIN_PASSWORD}" \
    --admin_email="${ADMIN_EMAIL}" \
    --skip-email \
    --allow-root
else
  echo "WordPress already installed."
fi

exec docker-entrypoint.sh apache2-foreground
