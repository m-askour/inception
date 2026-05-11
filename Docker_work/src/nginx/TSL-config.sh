# #!/bin/sh

# #use this script to run ther files and use the code inside of the configue and the dockerfile use to run it automatic li 
# #install the ssl certificate script
# # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout myndfun.key -out myndfin.crt

# set -e

# # 1. Create cert directory
# mkdir -p /etc/nginx/certs

# # 2. Generate certificate BEFORE nginx starts
# openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
# -subj "/CN=localhost" \
# -keyout /etc/nginx/certs/server.key \
# -out /etc/nginx/certs/server.crt

# # 3. Start nginx in foreground (VERY IMPORTANT)
# nginx -g "daemon off;"
# #openssl : use to  encryption , certifacates keys
# #-req :certificat requarment (use to creat the csr or directly creat the certificat like what i do )("-x509"=>gnerat the self-segned certificat directly)
# #-noods : No DES (no encryption) beacaus docker conainer must start automaticlly no interactive password
# #newkey : this to creat the new key and rsa -> encryption algorithm and the 2048-> this is the key size
# #keyout myndfun.key this is the output file for the privetkey "secretfile
# #out mynfin.crt: this is the output file certificat "public file"

#!/bin/bash
set -e

CERT_KEY="/etc/ssl/private/nginx-selfsigned.key"
CERT_CRT="/etc/ssl/certs/server.crt"

mkdir -p /etc/ssl/private /etc/ssl/certs

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout $CERT_KEY \
-out $CERT_CRT \
-subj "/C=MO/L=KH/O=1337/OU=student/CN=maskour.42.ma"

cat > /etc/nginx/conf.d/default.conf <<EOF
server {
    listen 443 ssl;
    listen [::]:443 ssl;

    server_name localhost;

    ssl_certificate $CERT_CRT;
    ssl_certificate_key $CERT_KEY;

    ssl_protocols TLSv1.2 TLSv1.3;

    root /var/www/html;
    index index.php;

    location ~ \.php$ {
        try_files \$uri =404;
        fastcgi_pass wordpress:9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
    }
}
EOF

nginx -g "daemon off;"