#!/bin/bas

###############################################################################
## Init enviroiment source
dir_path=$(dirname $0)
source $dir_path/config.cfg
source $dir_path/lib/functions.sh
source $dir_path/admin-openrc

### Running function
### Checking and help syntax command
if [ $# -ne 1 ]; then
        echocolor  "Syntax command "
        echo "Syntax command on Controller: bash $0 controller"
        echo "Syntax command on Compute1: bash $0 compute1"
        echo "Syntax command on Compute2: bash $0 compute2"
        exit 1;
fi

if [ "$1" == "controller" ]; then
		bash $dir_path/install/install_keystone.sh
        bash $dir_path/install/install_glance.sh
        bash $dir_path/install/install_nova.sh $1
        bash $dir_path/install/install_neutron.sh $1
        bash $dir_path/install/install_horizon.sh

elif [ "$1" == "compute1" ] || [ "$1" == "compute2" ]; then
	bash $dir_path/install/install_nova.sh $1
	bash $dir_path/install/install_neutron.sh $1

else
	echocolor "Error syntax"
    echocolor "Syntax command"
    echo "Syntax command on Controller: bash $0 controller"
    echo "Syntax command on Compute1: bash $0 compute1"
    echo "Syntax command on Compute2: bash $0 compute2"
	exit 1;

fi