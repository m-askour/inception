#!/bin/bash
set -e

cd /var/www/html

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

# 🔥 THIS FIXES YOUR ERROR
mkdir -p /run/php

# start PHP-FPM
exec /usr/sbin/php-fpm7.4 -F