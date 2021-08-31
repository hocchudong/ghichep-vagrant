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
apt update -qq -y >/dev/null 2>&1
apt install -qq -y net-tools >/dev/null 2>&1

echo "[TASK 4] Add user STACK"
useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
# Permission of `stack` directory is 0700 on CentOS 8, but it cause an
# error in a sanity check for the permission while running devstack
# installatino.
chmod 755 /opt/stack

echo "[TASK 5] Install Iptables"
apt-get install iptables -y  >/dev/null 2>&1
apt-get install arptables -y  >/dev/null 2>&1
apt-get install ebtables -y  >/dev/null 2>&1

update-alternatives --set iptables /usr/sbin/iptables-legacy || true
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy || true
update-alternatives --set arptables /usr/sbin/arptables-legacy || true
update-alternatives --set ebtables /usr/sbin/ebtables-legacy || true

echo "[TASK 6] Remove package"

sudo apt remove python3-simplejson -y   >/dev/null 2>&1
sudo apt remove python3-pyasn1-modules -y  >/dev/null 2>&1

echo "[TASK 7]Create file test"

touch cong.txt