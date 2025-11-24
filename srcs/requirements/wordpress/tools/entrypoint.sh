#!/bin/bash

echo "Inception: Waiting for MariaDB to be ready..."
until mariadb -hmariadb -u${DB_ADMIN_NAME} -p${DB_ADMIN_PWD} -e "SELECT 1;" > /dev/null 2>&1; do
    echo "MariaDB not ready yet, retrying in 2s..."
    sleep 2
done
echo "MariaDB is ready, continuing WordPress setup."

WP_PATH=/var/www/html

if ! [ -d $WP_PATH ]; then
    echo "Inception: Download core WordPress"
    wp core download --path=$WP_PATH --allow-root
fi

cd $WP_PATH;

if [ -f wp-config.php ] && wp core is-installed --allow-root; then
    echo "Inception: WordPress already installed"
else
    cp wp-config-sample.php wp-config.php

    wp config set --allow-root DB_HOST mariadb --path="."
    wp config set --allow-root DB_NAME ${DB_NAME} --path="."
    wp config set --allow-root DB_USER ${DB_ADMIN_NAME} --path="."
    wp config set --allow-root DB_PASSWORD "${DB_ADMIN_PWD}" --path="." --quiet

    wp config set --allow-root WP_DEBUG false --path="." --raw
    wp config set --allow-root WP_DEBUG_LOG false --path="." --raw

    wp config shuffle-salts --allow-root

    echo "wp-config.php file generated"

    echo "Installing WordPress"
    wp core install --allow-root \
        --path="." \
        --url=https://${DOMAIN} \
        --title="${WP_TITLE}" \
        --admin_user=${DB_ADMIN_NAME} \
        --admin_password=${DB_ADMIN_PWD} \
        --admin_email=${DB_ADMIN_EMAIL}

    wp plugin update --path="." --allow-root --all

    wp user create --path=$WP_PATH --allow-root \
        ${DB_USER_NAME} ${DB_USER_NAME}@${DOMAIN} --user_pass=${DB_USER_PWD} \
        --role=author --porcelain
fi

php-fpm7.4 -F
