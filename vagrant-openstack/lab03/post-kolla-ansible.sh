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

sendtelegram "Bat dau cai dat OpenStack bang kolla-ansible tren `hostname`"

kolla-ansible -i multinode bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

echo 'run-kolla.sh: Running kolla-ansible -i multinode prechecks'
kolla-ansible -i multinode prechecks

if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

echo 'run-kolla.sh: Running kolla-ansible -i multinode deploy'
kolla-ansible -i multinode deploy

if [ $? -ne 0 ]; then
  echo "Deploy failed"
  exit $?
fi

echo 'run-kolla.sh: Running sudo sudo kolla-ansible -i multinode post-deploy'
sudo kolla-ansible -i multinode post-deploy

cp /etc/kolla/admin-openrc.sh .
chmod +x admin-openrc.sh

# add-apt-repository cloud-archive:victoria
# apt update && apt dist-upgrade
# apt install python3-openstackclient -y

notify