#!/bin/bash
# Initial setup for the openstack guest machine
# The instructions were taken from https://docs.openstack.org/devstack/latest/

# Upgrade the guest machine
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Creates the openstack user and assign as passwordless sudoer
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/stack

sudo git clone https://opendev.org/openstack/devstack /opt/stack/devstack

# Parses the IP address for the guest VM
GUEST_IP=$(ip a | awk '/eth2:/ {parse_ip=1} parse_ip && /inet/ {print $2; exit}')

# Basic local.conf content
sudo echo '[[local|localrc]]
ADMIN_PASSWORD=Welcome123
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD
HOST_IP='${GUEST_IP%%/*}'
FLAT_INTERFACE=eth1
FLOATING_RANGE=172.16.16.224/27
FIXED_RANGE=10.11.12.0/24
FIXED_NETWORK_SIZE=256
SWIFT_REPLICAS=1

enable_plugin skyline https://opendev.org/skyline/skyline-apiserver

# enable_service s-proxy s-object s-container s-account
# enable_plugin heat https://opendev.org/openstack/heat
# enable_plugin heat-dashboard https://opendev.org/openstack/heat-dashboard
# enable_plugin magnum https://opendev.org/openstack/magnum
# enable_plugin magnum-ui https://opendev.org/openstack/magnum-ui
' > /opt/stack/devstack/local.conf

sudo chown stack:stack -R /opt/stack
