#!/bin/bash
set -e
openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key\
    -out /etc/ssl/certs/nginx-selfsigned.crt\
    -subj "/C=MO/L=KH/O=1337/OU=student/CN=$DOMAIN_NAME"

exec nginx -g "daemon off;"
