#!/bin/bash


###############################################################################
## Khai bao cac chuong trinh ho tro
source config.cfg
source functions.sh


###############################################################################
## Khai bao duong dan
path_hostname=/etc/hostname
path_interfaces=/etc/network/interfaces
path_hosts=/etc/hosts

###############################################################################
## Dinh nghia cac ham

function setup_ip_add {
    echocolor "Setup interfaces"
    sleep 3
    test -f $path_interfaces.orig || cp $path_interfaces $path_interfaces.orig

    if [ "$1" == "controller"]; then
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

    elif [ "$1" == "compute1" ]; then
        sed -i "/iface $MGNT_INTERFACE inet dhcp/c \
        iface $MGNT_INTERFACE inet static \n \
        address $COM1_MGNT_IP \n \
        netmask $NETMASK_ADD_MGNT" $path_interfaces

        sed -i "/iface $EXT_INTERFACE inet dhcp/c \
        iface $EXT_INTERFACE inet static \n \
        address $COM1_EXT_IP \n \
        netmask $NETMASK_ADD_EXT \n \
        gateway $GATEWAY_IP_EXT \n \
        dns-nameservers $DNS_IP" $path_interfaces

        sed -i "/iface $DATA_INTERFACE inet dhcp/c \
        iface $DATA_INTERFACE inet static \n \
        address $COM1_DATA_IP \n \
        netmask $NETMASK_ADD_EXT" $path_interfaces

    elif [ "$1" == "compute2" ]; then
        sed -i "/iface $MGNT_INTERFACE inet dhcp/c \
        iface $MGNT_INTERFACE inet static \n \
        address $COM2_MGNT_IP \n \
        netmask $NETMASK_ADD_MGNT" $path_interfaces

        sed -i "/iface $EXT_INTERFACE inet dhcp/c \
        iface $EXT_INTERFACE inet static \n \
        address $COM2_EXT_IP \n \
        netmask $NETMASK_ADD_EXT \n \
        gateway $GATEWAY_IP_EXT \n \
        dns-nameservers $DNS_IP" $path_interfaces

        sed -i "/iface $DATA_INTERFACE inet dhcp/c \
        iface $DATA_INTERFACE inet static \n \
        address $COM2_DATA_IP \n \
        netmask $NETMASK_ADD_EXT" $path_interfaces

    else
        echocolor "exit"
    fi
        
}

function setup_hostname {
    echocolor "Setup /etc/hostname"
    sleep 3
    
    if [ "$1" == "controller" ]; then
        echo "$HOST_CTL" > $path_hostname
        hostname -F $path_hostname
    
    elif ["$1" == "compute1" ]; then
        echo "$HOST_COM1" > $path_hostname
        hostname -F $path_hostname

    elif ["$1" == "compute2" ]; then
        echo "$HOST_COM2" > $path_hostname
        hostname -F $path_hostname
    else
        echocolor "Sai roi"
    fi

}

function setup_hosts {
    echocolor "Setup /etc/hosts"
    test -f $path_hosts.orig || cp $path_hosts $path_hosts.orig
    if [ "$1" == "controller" ]; then
        echo "127.0.0.1       localhost $HOST_CTL" > $path_hosts
        echo "$CTL_MGNT_IP    $HOST_CTL" >> $path_hosts
        echo "$COM1_MGNT_IP   $HOST_COM1" >> $path_hosts
        echo "$COM2_MGNT_IP   $HOST_COM2" >> $path_hosts
        echo "$CIN_MGNT_IP    $HOST_CIN" >> $path_hosts
    
    elif ["$1" == "compute1" ]; then
        echo "127.0.0.1       localhost $HOST_COM1" > $path_hosts
        echo "$CTL_MGNT_IP    $HOST_CTL" >> $path_hosts
        echo "$COM1_MGNT_IP   $HOST_COM1" >> $path_hosts
        echo "$COM2_MGNT_IP   $HOST_COM2" >> $path_hosts
        echo "$CIN_MGNT_IP    $HOST_CIN" >> $path_hosts

    elif ["$1" == "compute2" ]; then
        echo "127.0.0.1       localhost $HOST_COM1" > $path_hosts
        echo "$CTL_MGNT_IP    $HOST_CTL" >> $path_hosts
        echo "$COM1_MGNT_IP   $HOST_COM1" >> $path_hosts
        echo "$COM2_MGNT_IP   $HOST_COM2" >> $path_hosts
        echo "$CIN_MGNT_IP    $HOST_CIN" >> $path_hosts

    else
        echocolor "setup hostname sai roi"

    fi
    
}

function repo_openstack {
    echocolor "Enable the OpenStack Newton repository"
    sleep 3
    apt install software-properties-common -y
    add-apt-repository cloud-archive:newton -y
    echocolor "Upgrade the packages for server"
    sleep 3
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade
}

###############################################################################
## Thuc thi ham
setup_ip_add $1
setup_hostname $1
setup_hosts $1
# repo_openstack

# echocolor "Reboot Server"
# sleep 3
# init 6

