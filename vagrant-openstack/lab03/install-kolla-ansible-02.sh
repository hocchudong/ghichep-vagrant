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

echo "[TASK 1]Kolla-ansible bootstrap-servers"
sendtelegram "[TASK 1]Kolla-ansible bootstrap-servers"
kolla-ansible -i all-in-one bootstrap-servers

if [ $? -ne 0 ]; then
  echo "Bootstrap servers failed"
  exit $?
fi

echo "[TASK 2] Running kolla-ansible -i all-in-one prechecks"
sendtelegram "[TASK 2] Running kolla-ansible -i all-in-one prechecks"

kolla-ansible -i all-in-one prechecks

if [ $? -ne 0 ]; then
  echo "Prechecks failed"
  exit $?
fi

echo "[TASK 3] Running kolla-ansible -i all-in-one deploy"
sendtelegram "[TASK 3] Running kolla-ansible -i all-in-one deploy"

kolla-ansible -i all-in-one deploy

if [ $? -ne 0 ]; then
  echo "Deploy failed"
  exit $?
fi

echo "[TASK 4] Running sudo kolla-ansible -i all-in-one post-deploy"
sendtelegram "[TASK 4] Running sudo kolla-ansible -i all-in-one post-deploy"

kolla-ansible post-deploy

sendtelegram "Da cai dat xong kolla-ansible"
notify