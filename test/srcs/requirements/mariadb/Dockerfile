## Dockerfile for MariaDB
FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY tools/database.sh /usr/local/bin/database.sh
COPY conf/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /usr/local/bin/database.sh

CMD ["/usr/local/bin/database.sh"]