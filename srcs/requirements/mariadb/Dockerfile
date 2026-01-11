FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY --chmod=0755 ./tools/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
