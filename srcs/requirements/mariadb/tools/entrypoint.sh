#!/bin/bash

if [ ! -f "/run/mysqld/mysqld.pid" ]; then

	sed -i 's/= 127.0.0.1/= 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
	sed -i 's/basedir/port\t\t\t\t\t= 3306\nbasedir/' /etc/mysql/mariadb.conf.d/50-server.cnf

	echo "Inception: MariaDB config (50-server.cnf) updated."

	if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
		echo "Inception: Creating '${DB_NAME}' database..."

		service mariadb start

		mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"

		mysql -e "CREATE USER IF NOT EXISTS '${DB_ADMIN_NAME}'@'%' IDENTIFIED BY '${DB_ADMIN_PWD}';"
		mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_ADMIN_NAME}'@'%' IDENTIFIED BY '${DB_ADMIN_PWD}';"

		mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DB_ROOT_PWD}';"

		mysql -e "FLUSH PRIVILEGES;"

		mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';"

		mysqladmin -u root -p$DB_ROOT_PWD shutdown

	else
		echo "Inception: '${DB_NAME}' database already exists."
	fi
fi

exec mysqld_safe
