#!/bin/bash
set -e

DATADIR="/var/lib/mysql"
get_secret(){
    local secret_file="$1"
    local fallback="$2"
    if [ -n "$secret_file" ] && [ -f "$secret_file" ]; then
        cat "$secret_file"
    elif [ -n "$fallback" ]; then
        printf '%s\n' "$fallback"
    fi
}

MYSQL_PASSWORD="$(get_secret "${MYSQL_PASSWORD_FILE}" "${MYSQL_PASSWORD:-}")"
MYSQL_ROOT_PASSWORD="$(get_secret "${MYSQL_ROOT_PASSWORD_FILE}" "${MYSQL_ROOT_PASSWORD:-}")"

if [ ! -d "$DATADIR/mysql" ]; then
    mysql_install_db --user=mysql --datadir="$DATADIR" > /dev/null
fi

mysqld_safe --datadir="$DATADIR" --skip-networking &
pid="$!"

until mysqladmin ping --silent; do
    sleep 1
done

# Runs on every boot (not just first init) so the DB always matches
# whatever is currently in the secret files, even if the data volume
# already existed with an older password.
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