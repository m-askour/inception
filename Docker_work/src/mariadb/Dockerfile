FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY database.sh /usr/local/bin/database.sh
COPY mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN chmod +x /usr/local/bin/database.sh

EXPOSE 3306

CMD ["/usr/local/bin/database.sh"]