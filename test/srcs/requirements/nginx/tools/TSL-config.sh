#!/bin/bash
set -e

DOMAIN_NAME="${DOMAIN_NAME:-maskour.42.fr}"

CERT_KEY="/etc/ssl/private/nginx-selfsigned.key"
CERT_CRT="/etc/ssl/certs/nginx-selfsigned.crt"

mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$CERT_KEY" \
    -out "$CERT_CRT" \
    -subj "/C=MO/L=KH/O=1337/OU=student/CN=$DOMAIN_NAME"

exec nginx -g "daemon off;"
