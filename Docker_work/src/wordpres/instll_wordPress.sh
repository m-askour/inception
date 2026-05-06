#!/bin/bash

##this just to confique the php 
##https://developer.wordpress.org/advanced-administration/wordpress/wp-config/

if [ -f "wp-config.php" ]; then 
    echo "wordpress is already installed"
    #we change the db configue in the fie wp-config.php use this screept 
    # DB_HOSTNAME=mariadb
    # DB_NAME=wordpress
    # DB_USER=user 
    # DB_PASSWORD=password 
else
    echo "configuring wp-config.php"
    #copy the file 
    cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

    # define('DB_NAME', getenv('WORDPRESS_DB_NAME'));
    sed -i "s/database_name_here/$WORDPRESS_DB_NAME/g" /var/www/html/wp-config.php
    # define('DB_USER', getenv('WORDPRESS_DB_USER'));
    sed -i "s/username_here/$WORDPRESS_DB_USER/g" /var/www/html/wp-config.php
    # define('DB_PASSWORD', getenv('WORDPRESS_DB_PASSWORD'));
    sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/g" /var/www/html/wp-config.php
    
    # define('DB_HOST', getenv('WORDPRESS_DB_HOST'));
    sed -i "s/localhost/$WORDPRESS_DB_HOST/g" /var/www/html/wp-config.php
    
    echo "wp-config.php configured!"
fi