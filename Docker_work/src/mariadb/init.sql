    --  This is the SQL initialization script

-- This script tells MariaDB how to:
-- - Create the database
-- - Create the necessary user for WordPress
-- - Grant proper privileges

CREATE DATABASE IF NOT EXISTS wordpress;

-- Create user that can connect from any host (needed for Docker networking)
CREATE USER 'user'@'%' IDENTIFIED BY 'password';

-- Grant all privileges on wordpress database to the user
GRANT ALL PRIVILEGES ON wordpress.* TO 'user'@'%';

-- Flush privileges to apply changes immediately
FLUSH PRIVILEGES;
