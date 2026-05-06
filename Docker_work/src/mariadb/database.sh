#!/bin/sh

# Check if the database exists and is properly configured for WordPress

# Database connection details
DB_HOST="mariadb"
DB_USER="root"
DB_PASSWORD="password"
DB_NAME="wordpress"

echo "Checking database connection..."

# Test connection
if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; then
    echo "✓ Database connection successful"
else
    echo "✗ Database connection failed"
    exit 1
fi

echo "Checking if WordPress database exists..."

# Check if database exists
if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "USE $DB_NAME;" > /dev/null 2>&1; then
    echo "✓ WordPress database exists"
else
    echo "✗ WordPress database does not exist"
    exit 1
fi

echo "Checking WordPress user..."

# Check if user exists and has privileges
if mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SELECT User FROM mysql.user WHERE User='wordpress' AND Host='localhost';" | grep -q wordpress; then
    echo "✓ WordPress user exists"
else
    echo "✗ WordPress user does not exist"
    exit 1
fi

echo "Checking user privileges..."

# Check if user has privileges on wordpress database
PRIVILEGES=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASSWORD" -e "SHOW GRANTS FOR 'wordpress'@'localhost';" 2>/dev/null | grep wordpress)
if echo "$PRIVILEGES" | grep -q "ALL PRIVILEGES"; then
    echo "✓ WordPress user has proper privileges"
else
    echo "✗ WordPress user lacks proper privileges"
    exit 1
fi

echo "All checks passed! Database is ready for WordPress." 



