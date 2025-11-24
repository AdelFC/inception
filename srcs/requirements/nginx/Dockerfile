FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

COPY ./conf/nginx.conf /etc/nginx/sites-available/afodil-c.42.fr.conf

RUN openssl req -x509 \
    -sha256 \
    -nodes \
    -days 365 \
    -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=FR/ST=Ile-de-France/L=Paris/O=42/OU=afodil-c/CN=afodil-c.42.fr/"

RUN ln -s /etc/nginx/sites-available/afodil-c.42.fr.conf /etc/nginx/sites-enabled/afodil-c.42.fr.conf

EXPOSE 443

STOPSIGNAL SIGQUIT

CMD ["nginx", "-g", "daemon off;"]
