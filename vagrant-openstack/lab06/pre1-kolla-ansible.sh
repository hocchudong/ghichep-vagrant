#!/bin/bash
# Initial setup for the openstack guest machine
# The instructions were taken from https://docs.openstack.org/devstack/latest/

#!/bin/bash
notify() {
        chatid=1977142239
        token=1117214915:AAF4LFh6uChng056_oTyM6cz9TY4dyAn3YU

if [ $? -eq 0 ]
then
  curl -s --data-urlencode "text=I-AM-OK" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
else
  curl -s --data-urlencode "text=NOT-OK" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
fi

}

# Status
sendtelegram() {
        chatid=1977142239
        token=1117214915:AAF4LFh6uChng056_oTyM6cz9TY4dyAn3YU
        default_message="Test canh bao"

        curl -s --data-urlencode "text=$@" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
}

sendtelegram "Chuan bi moi truong cho kolla-ansible tren `hostname`"

cat << EOF > /etc/hosts
172.16.70.170 mgnt.hcdcloud.com
172.16.70.171 ctl01
172.16.70.175 com01
172.16.70.176 com02
172.16.70.179 nfs01
172.16.70.131 registry.hcdcloud.com
EOF

# Khai bao cho cinder-volume
pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb

apt update -y 
apt install sshpass -y

ssh-keygen -N "" -f /root/.ssh/id_rsa

sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@ctl01
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@com01
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@com02
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@nfs01

## Copy hostname 
scp /etc/hosts root@ctl01:/etc/hosts
scp /etc/hosts root@com01:/etc/hosts
scp /etc/hosts root@com02:/etc/hosts
scp /etc/hosts root@nfs01:/etc/hosts

# scp /etc/hosts root@compute03:/etc/hosts

echo "net.ipv4.ip_forward = 1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo sysctl -a | grep "net.ipv4.ip_forward ="

sudo apt update  -y

sudo apt-get install python3-dev libffi-dev gcc libssl-dev python3-pip -y

mkdir -p .config/pip

cat << EOF> .config/pip/pip.conf
[global]
index = https://172.16.70.131/repository/pip3proxy/pypi
index-url = https://172.16.70.131/repository/pip3proxy/simple
trusted-host = 172.16.70.131
EOF

sudo pip3 install -U pip
sudo pip3 install -U 'ansible<3.0'


## Cau hinh them cho ansible 

mkdir /etc/ansible

cat << EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF

# ln -svf /usr/bin/python3 /usr/bin/python

sudo pip3 install -U docker
sudo pip3 install kolla-ansible==12.2.0
# sudo pip3 install kolla-ansible==13.0.1

sudo mkdir -p /etc/kolla 
sudo chown $USER:$USER /etc/kolla 

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla 

cp /usr/local/share/kolla-ansible/ansible/inventory/* .

# sudo sed -i '/export ERL_EPMD_ADDRESS/d' /usr/local/share/kolla-ansible/ansible/roles/rabbitmq/templates/rabbitmq-env.conf.j2

cat /etc/kolla/globals.yml | egrep -v '^#|^$'

### Sua cau hinh 


sudo sed -i 's/^#openstack_release: .*$/openstack_release: "wallaby"/g'  /etc/kolla/globals.yml
# sudo sed -i 's/^#openstack_release: .*$/openstack_release: "xena"/g'  /etc/kolla/globals.yml

sudo sed -i 's/^#kolla_base_distro: .*$/kolla_base_distro: "ubuntu"/g'  /etc/kolla/globals.yml
sudo sed -i 's/^#kolla_install_type: .*$/kolla_install_type: "binary"/g'  /etc/kolla/globals.yml

# sudo sed -i 's/^#enable_heat: .*/enable_heat: "no"/g' /etc/kolla/globals.yml

sudo sed -i 's/^#kolla_internal_vip_address: .*/kolla_internal_vip_address: "172.16.70.170"/g' /etc/kolla/globals.yml
# sudo sed -i 's/^#kolla_internal_fqdn: .*/kolla_internal_fqdn: "mgnt.hcdcloud.com"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#docker_registry:.*/docker_registry: "registry.hcdcloud.com:8123"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#docker_registry_insecure:.*/docker_registry_insecure: "yes"/g' /etc/kolla/globals.yml

sudo sed -i 's/^#enable_cinder: .*/enable_cinder: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder_backend_lvm: .*/enable_cinder_backend_lvm: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#cinder_volume_group: .*/cinder_volume_group: "cinder-volumes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder_backup: .*/enable_cinder_backup: "no"/g' /etc/kolla/globals.yml
#sudo sed -i 's/^#enable_cinder_backup: .*/enable_cinder_backup: "yes"/g' /etc/kolla/globals.yml

# sudo sed -i 's/^#enable_haproxy: .*/enable_haproxy: "no"/g' /etc/kolla/globals.yml

sudo sed -i 's/^#network_interface: .*/network_interface: "eth2"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#neutron_external_interface: .*/neutron_external_interface: "eth3"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_neutron_provider_networks: .*/enable_neutron_provider_networks: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#nova_compute_virt_type: .*/nova_compute_virt_type: "qemu"/g' /etc/kolla/globals.yml

kolla-genpwd

sed -i 's/^keystone_admin_password.*/keystone_admin_password: Welcome123/' /etc/kolla/passwords.yml

## Sua cau hinh file inventory

sed -i 's/control01/ctl01/g' multinode
sed -i 's/control02/#controller02/g' multinode
sed -i 's/control03/#controller03/g' multinode


sed -i 's/network01/ctl01/g' multinode
sed -i 's/network02/#network02/g' multinode

sed -i 's/compute01/com01/g' multinode
sed -i '20 i com02' multinode

# sed -i '22 i compute03' multinode

sed -i 's/monitoring01/ctl01/g' multinode
sed -i 's/storage01/ctl01/g' multinode

notify
