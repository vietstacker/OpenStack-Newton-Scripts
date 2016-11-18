#!/bin/bash
## Install Keystone

###############################################################################
## Khai bao cac chuong trinh ho tro
dir_path=$(dirname $0)
source $dir_path/../config.cfg
source $dir_path/../lib/functions.sh

echocolor "Create Database for Keystone"

cat << EOF | mysql -uroot -p$MYSQL_PASS
CREATE DATABASE keystone default character set utf8;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$KEYSTONE_DBPASS' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$KEYSTONE_DBPASS' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echocolor "Install keystone"

# echo "manual" > /etc/init/keystone.override

apt-get -y install keystone --allow-unauthenticated

# Back-up file keystone.conf
path_keystone=/etc/keystone/keystone.conf
log_keystone=/var/log/keystone
test -f $path_keystone.orig || cp $path_keystone $path_keystone.orig

# Config file /etc/keystone/keystone.conf
# ops_edit $path_keystone DEFAULT admin_token $TOKEN_PASS

ops_edit $path_keystone database connection mysql+pymysql://keystone:$KEYSTONE_DBPASS@$CTL_MGNT_IP/keystone

ops_edit $path_keystone token provider fernet

#
su -s /bin/sh -c "keystone-manage db_sync" keystone

keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

echocolor "Bootstrap the Identity service"
sleep 3

keystone-manage bootstrap --bootstrap-password $ADMIN_PASS \
  --bootstrap-admin-url http://$CTL_MGNT_IP:35357/v3/ \
  --bootstrap-internal-url http://$CTL_MGNT_IP:35357/v3/ \
  --bootstrap-public-url http://$CTL_MGNT_IP:5000/v3/ \
  --bootstrap-region-id RegionOne
  
echocolor "Configure the Apache HTTP server"
sleep 3
echo "ServerName $CTL_MGNT_IP" >>  /etc/apache2/apache2.conf

systemctl restart apache2
rm -f /var/lib/keystone/keystone.db

export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://$CTL_MGNT_IP:35357/v3
export OS_IDENTITY_API_VERSION=3

openstack project create --domain default --description "Service Project" service

openstack project create --domain default --description "Demo Project" demo
openstack user create demo --domain default --password $ADMIN_PASS
openstack role create user
openstack role add --project demo --user demo user


unset OS_TOKEN OS_URL

# Create environment file
cat << EOF > admin-openrc
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$CTL_MGNT_IP:35357/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF

sleep 5
echocolor "Execute environment script"
chmod +x admin-openrc
cat  admin-openrc >> /etc/profile
cp  admin-openrc /root/admin-openrc
source admin-openrc


cat << EOF > demo-openrc
export OS_PROJECT_DOMAIN_NAME=default
export OS_USER_DOMAIN_NAME=default
export OS_PROJECT_NAME=demo
export OS_USERNAME=demo
export OS_PASSWORD=$DEMO_PASS
export OS_AUTH_URL=http://$CTL_MGNT_IP:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
chmod +x demo-openrc
cp  demo-openrc /root/demo-openrc

echocolor "Verifying keystone"
openstack token issue

