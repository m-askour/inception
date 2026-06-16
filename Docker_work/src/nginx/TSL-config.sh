#!/bin/bash
set -e

CERT_KEY="/etc/ssl/private/nginx-selfsigned.key"
CERT_CRT="/etc/ssl/certs/nginx-selfsigned.crt"

mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

openssl req -x509 -nodes -days 365 \
    -newkey rsa:2048 \
    -keyout "$CERT_KEY" \
    -out "$CERT_CRT" \
    -subj "/C=MO/L=KH/O=1337/OU=student/CN=maskour.42.fr"

cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name maskour.42.fr;

    ssl_certificate $CERT_CRT;
    ssl_certificate_key $CERT_KEY;

    ssl_protocols TLSv1.2 TLSv1.3;

    root /var/www/html;
    index index.php index.html;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ \.php$ {
        try_files \$uri =404;

        fastcgi_pass wordpress:9000;

        include fastcgi_params;

        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

exec nginx -g "daemon off;"