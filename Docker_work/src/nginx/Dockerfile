FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

COPY TSL-config.sh /usr/local/bin/TSL-config.sh

RUN chmod +x /usr/local/bin/TSL-config.sh

EXPOSE 443

CMD ["/usr/local/bin/TSL-config.sh"]