#!/bin/bash
set -e

cd /var/www/html

get_secret() {
    local secret_file="$1"
    local fallback="$2"

    if [ -n "$secret_file" ] && [ -f "$secret_file" ]; then
        cat "$secret_file"
    elif [ -n "$fallback" ]; then
        printf '%s' "$fallback"
    fi
}

WORDPRESS_DB_PASSWORD="$(get_secret "${WORDPRESS_DB_PASSWORD_FILE}" "${WORDPRESS_DB_PASSWORD:-}")"

echo "Waiting for MariaDB..."

until mysqladmin ping -h"$WORDPRESS_DB_HOST" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent; do
    sleep 2
done

if [ ! -f wp-config.php ]; then
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" wp-config.php
    sed -i "s/username_here/$WORDPRESS_DB_USER/g" wp-config.php
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" wp-config.php
    sed -i "s/localhost/$WORDPRESS_DB_HOST/g" wp-config.php
fi

mkdir -p /run/php

if [ -f /etc/php/7.4/fpm/pool.d/www.conf ]; then
    sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/7.4/fpm/pool.d/www.conf
fi

exec /usr/sbin/php-fpm7.4 -F