FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y curl php php-fpm php-mysql mariadb-client && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 ./tools/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
