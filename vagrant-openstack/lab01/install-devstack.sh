#!/bin/bash

######################################################
# Script de preparação da VM de convidado            #
# Versão: 1.0 - 18/07/21                             #
######################################################

# Atualização do sistema convidado
sudo apt update -y
sudo apt upgrade -y
sudo apt dist-upgrade -y

# Criação do usuário stack e sua inserção no sudoers
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/stack

# Clone do repositório Devstack
sudo git clone -bstable/wallaby https://opendev.org/openstack/devstack /opt/stack/devstack

# Criação do arquivo local.conf dentro repositório baixado
sudo echo '[[local|localrc]]
HOST_IP=172.16.70.189
FORCE=yes
ADMIN_PASSWORD=Welcome123
DATABASE_PASSWORD=$ADMIN_PASSWORD
RABBIT_PASSWORD=$ADMIN_PASSWORD
SERVICE_PASSWORD=$ADMIN_PASSWORD

disable_service etcd3

## Neutron options
Q_USE_SECGROUP=True
FLOATING_RANGE="172.16.16.0/24"
IPV4_ADDRS_SAFE_TO_USE="10.0.0.0/22"
Q_FLOATING_ALLOCATION_POOL=start=172.16.16.150,end=172.16.16.200
PUBLIC_NETWORK_GATEWAY="172.16.16.1"
PUBLIC_INTERFACE=eth1
IP_VERSION=4


# Open vSwitch provider networking configuration
Q_USE_PROVIDERNET_FOR_PUBLIC=True
OVS_PHYSICAL_BRIDGE=br-ex
PUBLIC_BRIDGE=br-ex
OVS_BRIDGE_MAPPINGS=public:br-ex

Q_ASSIGN_GATEWAY_TO_PUBLIC_BRIDGE=FALSE

# End of external network configuration

disable_service tempest

### Tuy chinh cau hinh cho neutron
[[post-config|/etc/neutron/dhcp_agent.ini]]
[DEFAULT]
enable_isolated_metadata = True' > /opt/stack/devstack/local.conf

# Mudando dono e grupo do diretório stack recursivamente para stack 
sudo chown stack:stack -R /opt/stack