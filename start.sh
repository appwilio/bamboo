#!/bin/bash
if [ ! -d /var/lib/mysql/mysql ]; then
	# Выставляем правильные права доступа
	chown mysql:mysql /var/lib/mysql
	
	# Инициализируем системные таблицы
	mysqld  --initialize-insecure --user=mysql
	service mysql start
	mysql -u root -e "CREATE DATABASE IF NOT EXISTS bamboo CHARACTER SET utf8 COLLATE utf8_bin;"
        mysql -u root -e "CREATE USER IF NOT EXISTS 'bamboo'@'localhost' IDENTIFIED BY '123456';"
	mysql -u root -e "GRANT all ON bamboo.* TO 'bamboo'@'localhost';"
else 
#chown mysql:mysql /var/lib/mysql
chown -R mysql /var/lib/mysql
service mysql start
fi

if [ -d /home/bamboo/ ]; then
	/home/bamboo/install/bin/start-bamboo.sh -fg
fi
