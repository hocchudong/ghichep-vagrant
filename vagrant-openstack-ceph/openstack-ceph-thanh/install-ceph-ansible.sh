#!/bin/bash 

apt update 

# Cai dat goi sshpass va copy keypair
apt install sshpass -y

ssh-keygen -N "" -f /root/.ssh/id_rsa

sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.41
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.42
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.43

# Khai bao file host 
cat << EOF > /etc/hosts
172.16.73.41 ceph01
172.16.73.42 ceph02
172.16.73.43 ceph03
172.16.73.44 ceph04

172.16.70.41 ceph01
172.16.70.42 ceph02
172.16.70.43 ceph03


127.0.0.1       localhost
EOF

# Copy file host 
scp /etc/hosts root@172.16.70.41:/etc/hosts
scp /etc/hosts root@172.16.70.42:/etc/hosts
scp /etc/hosts root@172.16.70.43:/etc/hosts

# Tai bo cai ceph-ansible
apt-get install python3-pip -y
git clone -b stable-6.0 https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
pip3 install -r requirements.txt

# khai bao file 
cp site.yml.sample site.yml
cp group_vars/all.yml.sample group_vars/all.yml
cp group_vars/osds.yml.sample group_vars/osds.yml


# Tao file 
cat << EOF > group_vars/all.yml
---
dummy:
cluster: ceph

monitor_interface: eth2
public_network: "172.16.73.0/24"
cluster_network: "172.16.74.0/24"
ip_version: ipv4

copy_admin_key: True
cephx: true

ceph_origin: repository
ceph_repository: community
ceph_stable_release: pacific
dashboard_enabled: false
# dashboard_protocol: https
# dashboard_port: 8443
# dashboard_admin_user: admin
# dashboard_admin_user_ro: false
# dashboard_admin_password: Welcome123
# grafana_admin_user: admin
# grafana_admin_password: admin
ntp_daemon_type: timesyncd
EOF

# Tao file osds.yml
cat << EOF > group_vars/osds.yml
---
dummy:
devices:
  - /dev/vdb
  - /dev/vdc

osd_auto_discovery: false
EOF

# Tao inventory file

cat << EOF > inventory.ini
[mons]
ceph01 ansible_host="172.16.70.41"
ceph02 ansible_host="172.16.70.42"
ceph03 ansible_host="172.16.70.43"

[osds:children]
mons

[mgrs:children]
mons

[monitoring:children]
mons
EOF

# Trien khai

# cd ceph-ansible
# ansible-playbook -i inventory.ini site.yml

echo "#######################"
echo "Thuc hien cac lenh sau"

echo "cd ceph-ansible"
echo "ansible-playbook -i inventory.ini site.yml"
