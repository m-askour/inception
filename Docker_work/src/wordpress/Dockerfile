FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget curl bash \
    php7.4 php7.4-fpm php7.4-mysql php7.4-cli php7.4-mbstring php7.4-gd \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 && \
    rm latest.tar.gz

COPY instll_wordPress.sh /usr/local/bin/instll_wordPress.sh
RUN chmod +x /usr/local/bin/instll_wordPress.sh

EXPOSE 9000

CMD ["/usr/local/bin/instll_wordPress.sh"]