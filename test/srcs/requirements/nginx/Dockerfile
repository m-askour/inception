FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -f /etc/nginx/sites-enabled/default && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/default.conf /etc/nginx/sites-available/default.conf

RUN ln -s /etc/nginx/sites-available/default.conf \
    /etc/nginx/sites-enabled/default.conf

COPY ./tools/TSL-config.sh /usr/local/bin/TSL-config.sh

RUN chmod +x /usr/local/bin/TSL-config.sh

EXPOSE 443

CMD ["/usr/local/bin/TSL-config.sh"]
