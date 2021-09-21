#!/bin/bash

######################################################
# Script de preparação da VM de convidado            #
# Versão: 1.0 - 18/07/21                             #
######################################################

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

sendtelegram "Tao moi truong cai dat cho dev stack"

echo "[TASK 2] TAO USER STACK"
sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/stack

echo "[TASK 3] Tai devstack"

echo "[TASK 5] PHAN QUYEN CHO CHU MUC CAI DEVSTACK"
sudo -u stack sh -c 'cp /tmp/local.conf /opt/stack/devstack'
sudo -u stack sh -c 'cd /opt/stack/devstack && ./stack.sh'

notify
