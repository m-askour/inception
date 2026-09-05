## Dockerfile for WordPress
FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    curl \
    php php-fpm php-mysql php-cli php-mbstring php-gd \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    curl -O https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz -C /var/www/html --strip-components=1 && \
    rm latest.tar.gz

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

COPY tools/install_wordPress.sh /usr/local/bin/install_wordPress.sh
RUN chmod +x /usr/local/bin/install_wordPress.sh


CMD ["/usr/local/bin/install_wordPress.sh"]