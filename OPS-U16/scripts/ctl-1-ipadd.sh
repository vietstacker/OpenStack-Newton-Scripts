#!/bin/bash
source config.cfg
source path.cfg
source functions.sh

## Dinh nghia ham

function setup_ip_add {
    echocolor "Setup interfaces"
    sleep 3
    test -f $path_interfaces.orig || cp $path_interfaces $path_interfaces.orig
    sed -i "/iface $MGNT_INTERFACE inet dhcp/c \
    iface $MGNT_INTERFACE inet static \n \
    address $CTL_MGNT_IP \n \
    netmask $NETMASK_ADD_MGNT" $path_interfaces

    sed -i "/iface $EXT_INTERFACE inet dhcp/c \
    iface $EXT_INTERFACE inet static \n \
    address $CTL_EXT_IP \n \
    netmask $NETMASK_ADD_EXT \n \
    gateway $GATEWAY_IP_EXT \n \
    dns-nameservers $DNS_IP" $path_interfaces
}

function setup_hostname {
    echocolor "Setup /etc/hostname"
    sleep 3
    echo "$HOST_CTL" > $path_hostname
    hostname -F $path_hostname
}

function setup_hosts {
    echocolor "Setup /etc/hosts"
    test -f $path_hosts.orig || cp $path_hosts $path_hosts.orig
    echo "127.0.0.1       localhost $HOST_CTL" > $path_hosts
    echo "$CTL_MGNT_IP    $HOST_CTL" >> $path_hosts
    echo "$COM1_MGNT_IP   $HOST_COM1" >> $path_hosts
    echo "$COM2_MGNT_IP   $HOST_COM2" >> $path_hosts
    echo "$CIN_MGNT_IP    $HOST_CIN" >> $path_hosts
    
}

function repo_openstack {
    echocolor "Enable the OpenStack Newton repository"
    sleep 3
    apt-get install software-properties-common -y
    add-apt-repository cloud-archive:newton -y
    echocolor "Upgrade the packages for server"
    sleep 3
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
}

## Thuc thi ham
setup_ip_add
setup_hostname
setup_hosts
repo_openstack

echocolor "Reboot Server"
sleep 3
init 6

