#!/bin/bash

# Télécharger WordPress si le volume est vide
if [ ! -f /var/www/html/wp-login.php ]; then
    wp core download --allow-root
fi

TIMEOUT=60
COUNT=0
until mysqladmin ping -h mariadb --silent || [ $COUNT -eq $TIMEOUT ]; do
    sleep 1
    COUNT=$((COUNT+1))
done

if [ $COUNT -eq $TIMEOUT ]; then
    echo "Error: MariaDB timeout after $TIMEOUT seconds"
    exit 1
fi

# Attendre que MariaDB soit vraiment prêt (pas juste ping)
echo "Waiting for MariaDB to be fully ready..."
sleep 5

if [ ! -f /var/www/html/wp-config.php ]; then
    wp config create \
        --dbname=${DB_NAME} \
        --dbuser=${DB_ADMIN_NAME} \
        --dbpass=${DB_ADMIN_PWD} \
        --dbhost=mariadb \
        --allow-root

    wp core install \
        --url=https://${DOMAIN} \
        --title="${WP_TITLE}" \
        --admin_user=${DB_ADMIN_NAME} \
        --admin_password=${DB_ADMIN_PWD} \
        --admin_email=${DB_ADMIN_EMAIL} \
        --allow-root

    wp user create ${DB_USER_NAME} ${DB_USER_NAME}@${DOMAIN} \
        --role=author \
        --user_pass=${DB_USER_PWD} \
        --allow-root
fi

mkdir -p /run/php
exec php-fpm7.4 -F
