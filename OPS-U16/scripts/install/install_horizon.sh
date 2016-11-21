#!/bin/bash
## Install HOZIRON

###############################################################################
## Init enviroiment source
dir_path=$(dirname $0)
source $dir_path/../config.cfg
source $dir_path/../lib/functions.sh

source admin-openrc

## PATH
filehtml=/var/www/html/index.html


echocolor "START INSTALLING OPS DASHBOARD"
###################
sleep 5

echocolor "Installing Dashboard package"
apt-get -y install openstack-dashboard
apt-get -y remove --auto-remove openstack-dashboard-ubuntu-theme

echocolor "Creating redirect page"
sleep 5

test -f $filehtml.orig || cp $filehtml $filehtml.orig
rm $filehtml
touch $filehtml
cat << EOF >> $filehtml
<html>
<head>
<META HTTP-EQUIV="Refresh" Content="0.5; URL=http://$CTL_EXT_IP/horizon">
</head>
<body>
<center> <h1>Redirecting to OpenStack Dashboard</h1> </center>
</body>
</html>
EOF

cp /etc/openstack-dashboard/local_settings.py \
    /etc/openstack-dashboard/local_settings.py.orig

# Allowing insert password in dashboard ( only apply in image )
sed -i "s/'can_set_password': False/'can_set_password': True/g" \
/etc/openstack-dashboard/local_settings.py

sed -i "s/_member_/user/g" /etc/openstack-dashboard/local_settings.py
sed -i "s/127.0.0.1/$CTL_MGNT_IP/g" /etc/openstack-dashboard/local_settings.py
sed -i "s/http:\/\/\%s:5000\/v2.0/http:\/\/\%s:5000\/v3/g" \
/etc/openstack-dashboard/local_settings.py

cat << EOF >> /etc/openstack-dashboard/local_settings.py
OPENSTACK_API_VERSIONS = {
#    "data-processing": 1.1,
    "identity": 3,
    "volume": 2,
    "compute": 2,
}
EOF


sed -i "s/DEFAULT_THEME = 'ubuntu'/DEFAULT_THEME = 'default'/g" \
	/etc/openstack-dashboard/local_settings.py

sed -i "s/#OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'default'/\
OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = 'default'/g" \
	/etc/openstack-dashboard/local_settings.py

## /* Restarting apache2 and memcached
service apache2 restart
service memcached restart
echocolor "Finish setting up Horizon"

echocolor "LOGIN INFORMATION IN HORIZON"
echocolor "URL: http://$CTL_EXT_IP/horizon"
echocolor "User: admin or demo"
echocolor "Password: $ADMIN_PASS"
