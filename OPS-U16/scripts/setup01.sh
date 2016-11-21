#!/bin/bash


###############################################################################
## Init enviroiment source
dir_path=$(dirname $0)
source $dir_path/config.cfg
source $dir_path/lib/functions.sh


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

    if [ "$1" == "controller" ]; then
        cat << EOF > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto $MGNT_INTERFACE
iface $MGNT_INTERFACE inet static
    address $CTL_MGNT_IP
    netmask $NETMASK_ADD_MGNT

# The primary network interface
auto $EXT_INTERFACE
iface $EXT_INTERFACE inet static
    address $CTL_EXT_IP
    netmask $NETMASK_ADD_EXT
    gateway $GATEWAY_IP_EXT
    dns-nameservers 8.8.8.8

# DATA VM
auto $DATA_INTERFACE
iface $DATA_INTERFACE inet static
    address $CTL_DATA_IP
    netmask $NETMASK_ADD_DATA
EOF

    elif [ "$1" == "compute1" ]; then
        cat << EOF > /etc/network/interfaces

# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto $MGNT_INTERFACE
iface $MGNT_INTERFACE inet static
    address $COM1_MGNT_IP
    netmask $NETMASK_ADD_MGNT


# The primary network interface
auto $EXT_INTERFACE
iface $EXT_INTERFACE inet static
    address $COM1_EXT_IP
    netmask $NETMASK_ADD_EXT
    gateway $GATEWAY_IP_EXT
    dns-nameservers 8.8.8.8

auto $DATA_INTERFACE
iface $DATA_INTERFACE inet static
    address $COM1_DATA_IP
    netmask $NETMASK_ADD_DATA

EOF

    elif [ "$1" == "compute2" ]; then
        cat << EOF > /etc/network/interfaces

# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto $MGNT_INTERFACE
iface $MGNT_INTERFACE inet static
    address $COM2_MGNT_IP
    netmask $NETMASK_ADD_MGNT


# The primary network interface
auto $EXT_INTERFACE
iface $EXT_INTERFACE inet static
    address $COM2_EXT_IP
    netmask $NETMASK_ADD_EXT
    gateway $GATEWAY_IP_EXT
    dns-nameservers 8.8.8.8

auto $DATA_INTERFACE
iface $DATA_INTERFACE inet static
    address $COM2_DATA_IP
    netmask $NETMASK_ADD_DATA

EOF

    else
        echocolor "Cau hinh network that bai"
        exit 1
    fi        
}

function setup_hostname {
    echocolor "Setup /etc/hostname"
    sleep 3
    
    if [ "$1" == "controller" ]; then
        echo "$HOST_CTL" > $path_hostname
        hostname -F $path_hostname
    
    elif [ "$1" == "compute1" ]; then
        echo "$HOST_COM1" > $path_hostname
        hostname -F $path_hostname

    elif [ "$1" == "compute2" ]; then
        echo "$HOST_COM2" > $path_hostname
        hostname -F $path_hostname
    else
        echocolor "Cau hinh hostname that bai"
        exit 1
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
    
    elif [ "$1" == "compute1" ]; then
        echo "127.0.0.1       localhost $HOST_COM1" > $path_hosts
        echo "$CTL_MGNT_IP    $HOST_CTL" >> $path_hosts
        echo "$COM1_MGNT_IP   $HOST_COM1" >> $path_hosts
        echo "$COM2_MGNT_IP   $HOST_COM2" >> $path_hosts
        echo "$CIN_MGNT_IP    $HOST_CIN" >> $path_hosts

    elif [ "$1" == "compute2" ]; then
        echo "127.0.0.1       localhost $HOST_COM2" > $path_hosts
        echo "$CTL_MGNT_IP    $HOST_CTL" >> $path_hosts
        echo "$COM1_MGNT_IP   $HOST_COM1" >> $path_hosts
        echo "$COM2_MGNT_IP   $HOST_COM2" >> $path_hosts
        echo "$CIN_MGNT_IP    $HOST_CIN" >> $path_hosts

    else
        echocolor "setup hostname sai roi"
        exit 1

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
### Running function
### Checking and help syntax command
if [ $# -ne 1 ]
    then
        echocolor  "Syntax command "
        echo "Syntax command on Controller: bash $0 controller"
        echo "Syntax command on Compute1: bash $0 compute1"
        echo "Syntax command on Compute2: bash $0 compute2"
        exit 1;
fi

### Goi ham thuc hiẹn
setup_ip_add $1
setup_hostname $1
setup_hosts $1
repo_openstack

echocolor "Reboot Server"
sleep 3
init 6

