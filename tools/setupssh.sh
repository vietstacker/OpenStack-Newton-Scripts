#!/bin/bash -ex
# Date: 25.07.2016
##################

echo "Setup ssh"
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig

echo "Allow ssh root"
sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl reload sshd