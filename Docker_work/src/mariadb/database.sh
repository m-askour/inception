#!/bin/bash
set -e

MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
MYSQL_USER="${MYSQL_USER:-wp_user}"
MYSQL_ADMIN_USER="${MYSQL_ADMIN_USER:-wp_admin}"

get_secret() {
    local secret_file="$1"
    local fallback="$2"

    if [ -n "$secret_file" ] && [ -f "$secret_file" ]; then
        cat "$secret_file"
    elif [ -n "$fallback" ]; then
        printf '%s' "$fallback"
    fi
}

MYSQL_PASSWORD="$(get_secret "${MYSQL_PASSWORD_FILE}" "${MYSQL_PASSWORD:-}")"
MYSQL_ADMIN_PASSWORD="$(get_secret "${MYSQL_ADMIN_PASSWORD_FILE}" "${MYSQL_ADMIN_PASSWORD:-}")"
MYSQL_ROOT_PASSWORD="$(get_secret "${MYSQL_ROOT_PASSWORD_FILE}" "${MYSQL_ROOT_PASSWORD:-}")"

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
fi

mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock --skip-networking=0 &
pid="$!"

until mysqladmin ping --silent; do
    sleep 1
done

cat > /tmp/init.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_ADMIN_USER}'@'%' IDENTIFIED BY '${MYSQL_ADMIN_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_ADMIN_USER}'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, ALTER, DROP ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock --skip-networking=0 --init-file=/tmp/init.sql