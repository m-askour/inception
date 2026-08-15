Step 0
Create docker-compose.yml
Step 1
Create Dockerfile for:
nginx
wordpress
mariadb
docker network

Step 2 --=> this for nginx
Configure TLS certificate (what's the defrence between the SSL"Secure Sockets Layer" and the TLS"Transport Layer Security")
openssl req -x509



Step 3 this is for --=> mariadb
Configure MariaDB database
Create:
wordpress database
user
admin



Step 4
Install WordPress
Configure:
wp-config.php




Step 5
Configure NGINX reverse proxy



Step 6
Create volumes
/home/login/data


Step 7
Run project
make


## this day is for the mariadb and wordpress


1- maryadb mysql creat database user
- creat BD
- creat user 
- grant privileges

in docker file the first is mamage the the mariadb continer 
 
## this day we work with wordpress and php

1- how the wordpress connects to the db 
2- wp-cofig.php
3- php-fpm concept



## this day for nginx + ssl




