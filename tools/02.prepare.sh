#!/bin/bash -ex
# Name: Script cai dat Mariadb
# Date: 22/07/2016
#######################################

echo "Installing Mariadb"
sleep 3
MYSQL_PASS='Welcome123'

echo mariadb-server-10.0 mysql-server/root_password $MYSQL_PASS | debconf-set-selections
echo mariadb-server-10.0 mysql-server/root_password_again MYSQL_PASS | debconf-set-selections
apt-get install -y  mariadb-server


sed -r -i 's/127\.0\.0\.1/0\.0\.0\.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/character-set-server  = utf8mb4/character-set-server  = utf8/' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/collation-server/#collation-server/' /etc/mysql/mariadb.conf.d/50-server.cnf

service mysql restart

cat << EOF | mysql -uroot -p'$MYSQL_PASS'
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'172.16.69.217' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;

CREATE DATABASE congtodb default character set utf8;
GRANT ALL PRIVILEGES ON congtodb.* TO 'congto'@'localhost' IDENTIFIED BY '$MYSQL_PASS'WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON congtodb.* TO 'congto'@'%' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'congto'@'172.16.69.217' IDENTIFIED BY '$MYSQL_PASS' WITH GRANT OPTION;
FLUSH PRIVILEGES;

FLUSH PRIVILEGES;

EOF
