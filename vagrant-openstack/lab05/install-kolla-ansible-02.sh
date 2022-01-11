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

sendtelegram "Bat dau cai dat kolla-ansible tren `hostname`"
touch loginstall.txt

echo "[TASK 1]Kolla-ansible bootstrap-servers"
echo "######### bootstrap-servers ##########" >> loginstall.txt
sendtelegram "[TASK 1]Kolla-ansible bootstrap-servers"

kolla-ansible -i all-in-one bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

echo "[TASK 2] Running kolla-ansible -i all-in-one prechecks"
sendtelegram "[TASK 2] Running kolla-ansible -i all-in-one prechecks"

kolla-ansible -i all-in-one prechecks

echo "######### Prechecks ##########"
if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

echo "[TASK 3] Running kolla-ansible -i all-in-one deploy"
sendtelegram "[TASK 3] Running kolla-ansible -i all-in-one deploy"

echo "######### deploy ##########" 


kolla-ansible -i all-in-one deploy

if [ $? -ne 0 ]; then
  echo "Deploy failed"
  exit $?
fi

echo "[TASK 4] Running sudo kolla-ansible -i all-in-one post-deploy"
sendtelegram "[TASK 4] Running sudo kolla-ansible -i all-in-one post-deploy"

echo "######### post-deploy##########" 

kolla-ansible -i all-in-one post-deploy 


cp /etc/kolla/admin-openrc.sh .
chmod +x admin-openrc.sh

# add-apt-repository cloud-archive:victoria -y
# apt update -y && apt dist-upgrade -y
# apt install python3-openstackclient -y
# cp /usr/local/share/kolla-ansible/init-runonce .
# sed -i 's/10.0.2/172.16.71/g' init-runonce
# sed -i 's/150/30/g' init-runonce
# sed -i 's/199/50/g' init-runonce

sendtelegram "Da cai dat xong kolla-ansible, truy cap vao de su dung"
notify
