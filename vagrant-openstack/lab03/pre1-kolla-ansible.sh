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
172.16.70.180 mgnt.hcdcloud.com
172.16.70.181 controller01
172.16.70.182 controller02
172.16.70.183 controller03
172.16.70.184 compute01
172.16.70.185 compute02
172.16.70.186 compute03
172.16.70.131 registry.hcdcloud.com
EOF

pvcreate /dev/vdb
vgcreate cinder-volumes /dev/vdb

sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 60/g' /etc/ssh/sshd_config
sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 60/g' /etc/ssh/sshd_config

systemctl restart sshd 


apt install sshpass -y

ssh-keygen -N "" -f /root/.ssh/id_rsa

sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@controller01
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@controller02
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@controller03

sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@compute01
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@compute02
sshpass -p hcdadmin ssh-copy-id -o StrictHostKeyChecking=no root@compute03

## Copy hostname 
scp /etc/hosts root@controller01:/etc/hosts
scp /etc/hosts root@controller02:/etc/hosts
scp /etc/hosts root@controller03:/etc/hosts

scp /etc/hosts root@compute01:/etc/hosts
scp /etc/hosts root@compute02:/etc/hosts
scp /etc/hosts root@compute03:/etc/hosts

## Cai dat goi bo tro 

sudo apt-get install git gcc python3-pip -y

sudo pip3 install --upgrade pip
sudo apt update  -y
sudo apt upgrade -y

systemctl disable ufw
systemctl stop ufw

notify
