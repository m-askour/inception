#!/bin/bash
set -e

cd /var/www/html
get_secret(){
    local secret_file="$1"
    local fallback="$2"
    if [ -n "$secret_file" ] && [ -f "$secret_file" ]; then
        cat "$secret_file"
    elif [ -n "$fallback" ]; then
        printf '%s\n' "$fallback"
    fi
}

WORDPRESS_DB_PASSWORD="$(get_secret "${WORDPRESS_DB_PASSWORD_FILE}" "${WORDPRESS_DB_PASSWORD:-}")"
WP_ADMIN_PASSWORD="$(get_secret "${WP_ADMIN_PASSWORD_FILE}" "${WP_ADMIN_PASSWORD:-}")"
WP_USER_PASSWORD="$(get_secret "${WP_USER_PASSWORD_FILE}" "${WP_USER_PASSWORD:-}")"

echo "Waiting for database to be ready..."

until mysqladmin ping -h"${WORDPRESS_DB_HOST%%:*}" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent 2>/dev/null; do
    sleep 2
done

if [ ! -f wp-load.php ]; then
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$WORDPRESS_DB_NAME" \
        --dbuser="$WORDPRESS_DB_USER" \
        --dbpass="$WORDPRESS_DB_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root
fi

if ! wp core is-installed --allow-root 2>/dev/null; then
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email --allow-root

    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author --user_pass="${WP_USER_PASSWORD}" --allow-root
fi

chown -R www-data:www-data /var/www/html
mkdir -p /run/php

sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

exec /usr/sbin/php-fpm8.2 -F