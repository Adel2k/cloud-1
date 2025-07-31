#!/bin/bash

set -e

echo "Waiting for database..."
until wp db check --allow-root; do
  sleep 2
done


if ! wp core is-installed --allow-root; then
  echo "Installing WordPress..."
  wp core install \
    --url="http://localhost" \
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
