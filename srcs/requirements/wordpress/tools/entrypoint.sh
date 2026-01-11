#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

WP_PATH=/var/www/html

sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf
mkdir -p /run/php

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    wp core download --path=$WP_PATH --allow-root

    wp config create --allow-root \
        --path=$WP_PATH \
        --dbhost=mariadb \
        --dbname=$DB_NAME \
        --dbuser=$DB_ADMIN_NAME \
        --dbpass="$DB_PASSWORD"

    wp core install --allow-root \
        --path=$WP_PATH \
        --url=https://$DOMAIN \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_NAME \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email=$WP_ADMIN_EMAIL

    wp user create $WP_USER_NAME $WP_USER_EMAIL \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author \
        --allow-root \
        --path=$WP_PATH
fi

/usr/sbin/php-fpm8.2 -F
