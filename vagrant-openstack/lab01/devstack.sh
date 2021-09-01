#!/bin/bash

echo "CREATE STACK USER..."
useradd -s /bin/bash -d /opt/stack -m stack
echo "stack ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/stack

echo "CLONING DEVSTACK REPO..."
su - stack -c 'git clone https://opendev.org/openstack/devstack/'
su - stack -c 'cd devstack && git checkout stable/wallaby'
echo "COPY LOCAL.CONF..."
sudo -u stack sh -c 'cp /tmp/local.conf /opt/stack/devstack'
sudo -u stack sh -c 'cp /tmp/cirros-0.5.2-x86_64-disk.img /opt/stack/devstack/files'

echo "BUILDING DEVSTACK... THIS TAKES AWHILE..."
su - stack -c './devstack/stack.sh'