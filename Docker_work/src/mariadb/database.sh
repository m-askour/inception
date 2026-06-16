#!/bin/bash
set -e

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld_safe &
pid="$!"

# Wait for MariaDB to be ready
until mysqladmin ping --silent; do
    sleep 1
done

# Create database and user only once
mysql << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

mysqladmin shutdown

wait "$pid"

exec mysqld_safe