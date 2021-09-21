#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hcdadmin\nhcdadmin" | passwd root >/dev/null 2>&1

# Install package
echo "[TASK 3] Install net-tools"
sudo apt update -y  >/dev/null 2>&1
sudo apt upgrade -y  >/dev/null 2>&1
sudo apt dist-upgrade -y  >/dev/null 2>&1
sudo apt install net-tools -qq -y >/dev/null 2>&1

