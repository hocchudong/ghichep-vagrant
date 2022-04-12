#!/bin/bash 

apt update 

# Cai dat goi sshpass va copy keypair
apt install sshpass -y

ssh-keygen -N "" -f /root/.ssh/id_rsa

sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.161
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.162
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.163
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@172.16.70.164

# Khai bao file host 
cat << EOF > /etc/hosts
172.16.73.161 ceph01
172.16.73.162 ceph02
172.16.73.163 ceph03
172.16.73.164 ceph04
172.16.73.169 client01

172.16.70.161 ceph01
172.16.70.162 ceph02
172.16.70.163 ceph03
172.16.70.164 ceph04
172.16.70.169 client01

172.16.73.161 ceph01ssd
172.16.73.162 ceph02ssd
172.16.73.163 ceph03ssd
172.16.73.164 ceph04ssd

172.16.73.161 ceph01ssd
172.16.73.162 ceph02ssd
172.16.73.163 ceph03ssd
172.16.73.164 ceph04ssd

127.0.0.1       localhost
EOF

# Copy file host 
scp /etc/hosts root@172.16.70.161:/etc/hosts
scp /etc/hosts root@172.16.70.162:/etc/hosts
scp /etc/hosts root@172.16.70.163:/etc/hosts
scp /etc/hosts root@172.16.70.164:/etc/hosts

# Tai bo cai ceph-ansible
apt-get install python3-pip -y
git clone -b stable-6.0 https://github.com/ceph/ceph-ansible.git
cd ceph-ansible
pip3 install -r requirements.txt

# khai bao file 
cp site.yml.sample site.yml
cp group_vars/all.yml.sample group_vars/all.yml
# cp group_vars/osds.yml.sample group_vars/osds.yml

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

# # # Tao file osds.yml
# # cat << EOF > group_vars/osds.yml
# # ---
# # dummy:
# # devices:
  # # - /dev/vdb
  # # - /dev/vdc

# # osd_auto_discovery: false
# # EOF

# Tao inventory file

cat << EOF > inventory1.ini
[mons]
ceph01 ansible_host="172.16.70.161"
ceph02 ansible_host="172.16.70.162"
ceph03 ansible_host="172.16.70.163"
ceph04 ansible_host="172.16.70.164"

[ceph01_hdd]
ceph01 devices="['/dev/vdc', '/dev/vdd' ]" dedicated_devices="['/dev/vdb']" osd_crush_location="{ 'root': 'default', 'host': 'ceph01' }" crush_device_class="hdd"

[ceph02_hdd]
ceph02 devices="['/dev/vdc', '/dev/vdd' ]" dedicated_devices="['/dev/vdb']" osd_crush_location="{ 'root': 'default', 'host': 'ceph02' }" crush_device_class="hdd"

[ceph03_hdd]
ceph03 devices="['/dev/vdc', '/dev/vdd' ]" dedicated_devices="['/dev/vdb']" osd_crush_location="{ 'root': 'default', 'host': 'ceph03' }" crush_device_class="hdd"

[ceph04_hdd]
ceph04 devices="['/dev/vdc', '/dev/vdd' ]" dedicated_devices="['/dev/vdb']" osd_crush_location="{ 'root': 'default', 'host': 'ceph04' }" crush_device_class="hdd"

[osds:children]
ceph01_hdd
ceph02_hdd
ceph03_hdd
ceph04_hdd

[mgrs:children]
mons

[monitoring:children]
mons
EOF

cat << EOF > inventory2.ini
[mons]
ceph01ssd ansible_host="172.16.70.161"
ceph02ssd ansible_host="172.16.70.162"
ceph03ssd ansible_host="172.16.70.163"
ceph04ssd ansible_host="172.16.70.164"

[ceph01_ssd]
ceph01ssd devices="['/dev/vde', '/dev/vdf' ]" osd_crush_location="{ 'root': 'default', 'host': 'ceph01' }" crush_device_class="ssd"

[ceph02_ssd]
ceph02ssd devices="['/dev/vde', '/dev/vdf' ]" osd_crush_location="{ 'root': 'default', 'host': 'ceph02' }" crush_device_class="ssd"

[ceph03_ssd]
ceph03ssd devices="['/dev/vde', '/dev/vdf' ]" osd_crush_location="{ 'root': 'default', 'host': 'ceph03' }" crush_device_class="ssd"

[ceph04_ssd] 
ceph04ssd devices="['/dev/vde', '/dev/vdf' ]" osd_crush_location="{ 'root': 'default', 'host': 'ceph04' }" crush_device_class="ssd"

[osds:children]

ceph01_ssd
ceph02_ssd
ceph03_ssd
ceph04_ssd

[mgrs:children]
mons

[monitoring:children]
mons
EOF

# Trien khai

echo "### THUC THI CAC LENH DUOI ###"
echo "cd ceph-ansible"
echo "ansible-playbook -i inventory1.ini site.yml"
echo "ansible-playbook -i inventory2.ini site.yml --limit osds"

# cd ceph-ansible
# ansible-playbook -i inventory1.ini site.yml
# ansible-playbook -i inventory2.ini site.yml --limit osds

