#!/bin/bash

######################################################
# Script de preparação da VM de convidado            #
# Versão: 1.0 - 18/07/21                             #
######################################################

 
echo "[TASK 2] TAO USER STACK"
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/stack

echo "[TASK 3] Tai devstack"

echo "[TASK 5] PHAN QUYEN CHO CHU MUC CAI DEVSTACK"
sudo -u stack sh -c 'cp /tmp/local.conf /opt/stack/devstack'
sudo -u stack sh -c 'cd /opt/stack/devstack && ./stack.sh'
