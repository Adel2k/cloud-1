#!/bin/bash

set -e 

setup_directory() {
    echo "Setting up directory..."
    mkdir -p "$WP_PATH"
    cd "$WP_PATH" || exit 1
    chmod -R 755 "$WP_PATH"
    chown -R www-data:www-data "$WP_PATH"
}

download_wordpress() {
    echo "Downloading WordPress..."
    rm -rf ./*
    wp core download --allow-root
}

configure_wordpress() {
    echo "Configuring WordPress..."
    cp wp-config-sample.php wp-config.php
    sed -i "s/database_name_here/${MYSQL_DATABASE}/" wp-config.php
    sed -i "s/username_here/${MYSQL_USER}/" wp-config.php
    sed -i "s/password_here/${MYSQL_PASSWORD}/" wp-config.php
    sed -i "s/'localhost'/'db'/" wp-config.php
}

install_wordpress() {
    cd "$WP_PATH"

    until wp db check --allow-root &>/dev/null; do
        echo "MySQL not ready yet..."
        sleep 2
    done
    echo "✅ MySQL is up."
    echo "🔍 Testing MySQL connection..."
    if ! mysql -h db -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "❌ Cannot connect to MySQL database. Exiting setup."
        exit 1
    else
        echo "MySQL connection OK."
    fi

    if wp core is-installed --allow-root; then
        echo "WordPress is already installed."
        return
    fi

    echo "Installing WordPress core..."
    wp core install \
        --url="https://ampik1.duckdns.org" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ROOT_USER_USERNAME" \
        --admin_password="$WP_ROOT_USER_PASSWORD" \
        --admin_email="$WP_ROOT_USER_EMAIL" \
        --skip-email \
        --allow-root

    echo "Creating additional user..."
    wp user create "$WP_USER_USERNAME" "$WP_USER_EMAIL" \
        --role="$WP_USER_ROLE" \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root || echo "User may already exist."
}

setup_permissions() {
    echo "Setting up permissions..."
    chmod -R 755 "$WP_PATH"
    chown -R www-data:www-data "$WP_PATH"
}

update_wordpress() {
    echo "⬆Updating WordPress..."
    wp core update --allow-root || echo "WordPress update failed."
}

install_plugins() {
    echo "Installing and updating plugins..."
    wp plugin install redis-cache --activate --allow-root
    wp plugin update --all --allow-root
}

cleanup() {
    echo "Cleaning up..."
    rm -f wp-config-sample.php
}

start_php() {
    echo "Starting PHP-FPM..."
    exec /usr/sbin/php-fpm7.4 -F
}

setup_directory

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    download_wordpress
    configure_wordpress
    install_wordpress
    setup_permissions
    install_plugins
    cleanup
else
    echo "✅ WordPress already configured. Skipping setup."
fi

update_wordpress
start_php
