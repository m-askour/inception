## Dockerfile for Nginx
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /etc/nginx/sites-enabled/default && \
    rm -rf /var/lib/apt/lists/*

COPY tools/TSL-config.sh /usr/local/bin/TSL-config.sh

RUN chmod +x /usr/local/bin/TSL-config.sh

EXPOSE 443

CMD ["/usr/local/bin/TSL-config.sh"]