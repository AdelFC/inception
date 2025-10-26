#!/bin/bash

echo "CREATE DATABASE IF NOT EXISTS ${DB_NAME};" > /etc/mysql/init.sql
echo "CREATE USER IF NOT EXISTS '${DB_ADMIN_NAME}'@'%' IDENTIFIED BY '${DB_ADMIN_PWD}';" >> /etc/mysql/init.sql
echo "CREATE USER IF NOT EXISTS '${DB_USER_NAME}'@'%' IDENTIFIED BY '${DB_USER_PWD}';" >> /etc/mysql/init.sql
echo "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_ADMIN_NAME}'@'%';" >> /etc/mysql/init.sql
echo "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER_NAME}'@'%';" >> /etc/mysql/init.sql
echo "ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';" >> /etc/mysql/init.sql
echo "FLUSH PRIVILEGES;" >> /etc/mysql/init.sql

exec mysqld_safe --init-file=/etc/mysql/init.sql
