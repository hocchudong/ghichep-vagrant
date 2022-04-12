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

sendtelegram "Cai dat kolla-ansible tren `hostname`"


## Lua chon cac goi de cai dat OpenStack Victoria
pip3 install -U 'ansible<2.9.19'
pip3 install kolla-ansible==11.0.0

## Lua chon cac goi de cai dat OpenStack Wallaby
# pip3 install 'ansible<3.0'
# pip3 install 'kolla-ansible==12.2'

# Cau hinh cho ansible

mkdir /etc/ansible

cat << EOF > /etc/ansible/ansible.cfg
[defaults]
host_key_checking=False
pipelining=True
forks=100
EOF

sudo mkdir -p /etc/kolla
sudo chown $USER:$USER /etc/kolla

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla
cp /usr/local/share/kolla-ansible/ansible/inventory/* .

## Sua file config
echo "Cau hinh Kolla-Ansible"
sudo sed -i '/export ERL_EPMD_ADDRESS/d' /usr/local/share/kolla-ansible/ansible/roles/rabbitmq/templates/rabbitmq-env.conf.j2

sudo sed -i 's/^#openstack_release: .*$/openstack_release: "victoria"/g'  /etc/kolla/globals.yml
## bo comment neu muon cai OpenStack Wallaby
# sudo sed -i 's/^#openstack_release: .*$/openstack_release: "wallaby"/g'  /etc/kolla/globals.yml


sudo sed -i 's/^#kolla_base_distro: .*$/kolla_base_distro: "ubuntu"/g'  /etc/kolla/globals.yml
sudo sed -i 's/^#enable_heat: .*/enable_heat: "no"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder: .*/enable_cinder: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder_backend_lvm: .*/enable_cinder_backend_lvm: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#cinder_volume_group: .*/cinder_volume_group: "cinder-volumes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder_backup: .*/enable_cinder_backup: "no"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#nova_compute_virt_type: .*/nova_compute_virt_type: "qemu"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_haproxy: .*/enable_haproxy: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#kolla_internal_vip_address: .*/kolla_internal_vip_address: "172.16.70.180"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#kolla_internal_fqdn: .*/kolla_internal_fqdn: "mgnt.hcdcloud.com"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#docker_registry:.*/docker_registry: "registry.hcdcloud.com:8123"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#network_interface: .*/network_interface: "eth2"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#neutron_external_interface: .*/neutron_external_interface: "eth3"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_neutron_provider_networks: .*/enable_neutron_provider_networks: "yes"/g' /etc/kolla/globals.yml

# sudo sed -i 's/localhost/aiokolla/g' all-in-one 

kolla-genpwd

sudo sed -i 's/^keystone_admin_password.*/keystone_admin_password: Welcome123/' /etc/kolla/passwords.yml

sed -i 's/control01/controller01/g' multinode
sed -i 's/control02/controller02/g' multinode
sed -i 's/control03/controller03/g' multinode


sed -i 's/network01/controller01/g' multinode
sed -i 's/network02/controller02/g' multinode
sed -i '17 i controller03' multinode

sed -i '21 i compute02' multinode
# sed -i '22 i compute03' multinode


sed -i 's/monitoring01/controller01/g' multinode
sed -i 's/storage01/controller01/g' multinode








