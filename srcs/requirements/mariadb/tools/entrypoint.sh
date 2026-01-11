#!/bin/bash

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
	echo "Inception: Creating '${DB_NAME}' database..."

	service mariadb start

	mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
	mysql -e "CREATE USER IF NOT EXISTS '${DB_ADMIN_NAME}'@'%' IDENTIFIED BY '${DB_PASSWORD}';"
	mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_ADMIN_NAME}'@'%';"
	mysql -e "FLUSH PRIVILEGES;"

	mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';"
	mysqladmin -u root -p${DB_ROOT_PASSWORD} shutdown
else
	echo "Inception: '${DB_NAME}' database already exists."
fi

exec mysqld_safe
