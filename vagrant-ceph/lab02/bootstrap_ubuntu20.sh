#!/bin/bash

DATE_EXEC="$(date "+%d/%m/%Y %H:%M")"
TIME_START=`date +%s.%N`

## Khai bao cac ham
function notify() {
    chatid=-557175523
    #token=1117214915:AAF4LFh6uChng056_oTyM6cz9TY4dyAn3YU
    token=2004478698:AAEsHPaCw_mbTsCaxtV2YoTAdmi1cB6N9Rw

if [ $? -eq 0 ]
then
  curl -s --data-urlencode "text=I-AM-OK" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
  curl -s --data-urlencode "text=#######" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
else
  curl -s --data-urlencode "text=NOT-OK" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
  curl -s --data-urlencode "text=#######" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
fi

}

# Status
function sendtelegram() {
  chatid=-557175523
  #token=1117214915:AAF4LFh6uChng056_oTyM6cz9TY4dyAn3YU
  token=2004478698:AAEsHPaCw_mbTsCaxtV2YoTAdmi1cB6N9Rw
  default_message="Test canh bao"
  curl -s --data-urlencode "text=$@" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
}


function repo(){
  touch /etc/apt/apt.conf.d/99verify-peer.conf
  echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }"
  cp /etc/apt/sources.list /etc/apt/sources.list.bka

cat << EOF > /etc/apt/sources.list
deb https://172.16.70.131/repository/ubuntu2004 focal main restricted
deb https://172.16.70.131/repository/ubuntu2004 focal-updates main restricted
deb https://172.16.70.131/repository/ubuntu2004 focal universe
deb https://172.16.70.131/repository/ubuntu2004 focal-updates universe
deb https://172.16.70.131/repository/ubuntu2004 focal multiverse
deb https://172.16.70.131/repository/ubuntu2004 focal-updates multiverse
deb https://172.16.70.131/repository/ubuntu2004 focal-backports main restricted universe multiverse
deb https://172.16.70.131/repository/ubuntu2004 focal-security main restricted
deb https://172.16.70.131/repository/ubuntu2004 focal-security universe
deb https://172.16.70.131/repository/ubuntu2004 focal-security multiverse
EOF
    apt clean
    apt-get update
}

function install_ntp(){
  sed -i 's/#NTP=/NTP=172.16.70.12/g' /etc/systemd/timesyncd.conf
  timedatectl set-ntp off
  timedatectl set-ntp on
  timedatectl timesync-status
}


# sendtelegram "Thuc hien script $0 tren `hostname`"
# sendtelegram "Setup co ban tren node `hostname`"

echo "[TASK 1]Khai bao repo node `hostname`"
repo

# Enable ssh password authentication
echo "[TASK 2] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 3] Set root password"
echo -e "hcdadmin\nhcdadmin" | passwd root >/dev/null 2>&1

# Install package
echo "[TASK 4] Install package"
apt-get update -qq -y >/dev/null 2>&1
# apt-get dist-upgrade -qq -y >/dev/null 2>&1
apt-get install -qq -y net-tools git curl vim byobu crudini bc >/dev/null 2>&1

# Config basic
echo "[TASK 5] Config basic"
systemctl disable ufw
systemctl stop ufw
timedatectl set-timezone Asia/Ho_Chi_Minh

echo "[TASK 6]Khai bao install_ntp node `hostname`"
install_ntp

TIME_END=`date +%s.%N`
TIME_TOTAL_TEMP=$( echo "$TIME_END - $TIME_START" | bc -l )
TIME_TOTAL=$(cut -c-6 <<< "$TIME_TOTAL_TEMP")

echo "Da thuc hien script $0 tren `hostname`"
echo "Tong thoi gian thuc hien $0 tren `hostname`: $TIME_TOTAL giay"

sendtelegram "Da thuc hien script $0"
sendtelegram "Tong thoi gian thuc hien $0 tren `hostname`: $TIME_TOTAL giay"
# notify
