#!/bin/bash


###############################################################################
## Khai bao cac chuong trinh ho tro
dir_path=$(dirname $0)
source $dir_path/config.cfg
source $dir_path/functions.sh

if [ "$1" == "controller" ]; then
	bash $dir_path/install/install_keystone.sh
else
	echocolor "Xin chao"
	exit 1;