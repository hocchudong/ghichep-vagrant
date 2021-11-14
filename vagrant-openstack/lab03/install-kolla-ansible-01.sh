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

echo "[TASK 1] Thiet lap hostname"
sudo echo "172.16.70.188 aiokolla" > /etc/hosts
sudo echo "172.16.70.131 registry.hcdcloud.com" >> /etc/hosts
sudo pvcreate /dev/vdb >/dev/null 2>&1
sudo vgcreate cinder-volumes /dev/vdb >/dev/null 2>&1

echo "[TASK 2] Cai dat cac goi can thiet"
sudo apt update -qq -y >/dev/null 2>&1
sudo apt upgrade  -qq -y >/dev/null 2>&1
sudo apt install python3-pip -qq -y >/dev/null 2>&1
sudo apt install python3-dev libffi-dev gcc libssl-dev -qq -y >/dev/null 2>&1

sudo pip3 install -U pip >/dev/null 2>&1
sudo pip3 install -U 'ansible<2.10' >/dev/null 2>&1
# ln -svf /usr/bin/python3 /usr/bin/python
sudo pip3 install -U docker >/dev/null 2>&1

echo "[TASK 3] Cai dat Kolla-Ansible"
sudo pip3 install kolla-ansible==11.0.0  >/dev/null 2>&1

sudo mkdir -p /etc/kolla 
sudo chown $USER:$USER /etc/kolla 

cp -r /usr/local/share/kolla-ansible/etc_examples/kolla/* /etc/kolla 
cp /usr/local/share/kolla-ansible/ansible/inventory/* .

echo "[TASK 4] Cau hinh Kolla-Ansible"
sudo sed -i '/export ERL_EPMD_ADDRESS/d' /usr/local/share/kolla-ansible/ansible/roles/rabbitmq/templates/rabbitmq-env.conf.j2

sudo sed -i 's/^#openstack_release: .*$/openstack_release: "victoria"/g'  /etc/kolla/globals.yml
sudo sed -i 's/^#kolla_base_distro: .*$/kolla_base_distro: "ubuntu"/g'  /etc/kolla/globals.yml
sudo sed -i 's/^#enable_heat: .*/enable_heat: "no"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder: .*/enable_cinder: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#nova_compute_virt_type: .*/nova_compute_virt_type: "qemu"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder_backend_lvm: .*/enable_cinder_backend_lvm: "yes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#docker_registry:.*/docker_registry: "registry.hcdcloud.com:8123"/g' /etc/kolla/globals.yml

sudo sed -i 's/^#cinder_volume_group: .*/cinder_volume_group: "cinder-volumes"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_cinder_backup: .*/enable_cinder_backup: "no"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_haproxy: .*/enable_haproxy: "no"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#kolla_internal_vip_address: .*/kolla_internal_vip_address: "172.16.70.188"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#network_interface: .*/network_interface: "eth2"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#neutron_external_interface: .*/neutron_external_interface: "eth3"/g' /etc/kolla/globals.yml
sudo sed -i 's/^#enable_neutron_provider_networks: .*/enable_neutron_provider_networks: "yes"/g' /etc/kolla/globals.yml


sudo sed -i 's/localhost/aiokolla/g' all-in-one 

kolla-genpwd

sudo sed -i 's/^keystone_admin_password.*/keystone_admin_password: Welcome123/' /etc/kolla/passwords.yml

sendtelegram "Da cai dat xong moi truong co ban de cai kolla-ansible"

notify