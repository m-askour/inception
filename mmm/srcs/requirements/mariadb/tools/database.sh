#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

if [ ! -d "$DATADIR/mysql" ]; then
    mysql_install_db --user=mysql --datadir="$DATADIR" > /dev/null
fi

mysqld_safe --datadir="$DATADIR" --skip-networking &
pid="$!"

until mysqladmin ping --silent; do
    sleep 1
done

mysql -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

mysqladmin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
wait "$pid"

exec mysqld_safe --datadir="$DATADIR"
