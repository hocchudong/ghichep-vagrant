#!/bin/bash

DATE_EXEC="$(date "+%d/%m/%Y %H:%M")"
TIME_START=`date +%s.%N`

## Khai bao cac ham
function notify() {
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
function sendtelegram() {
        chatid=1977142239
        token=1117214915:AAF4LFh6uChng056_oTyM6cz9TY4dyAn3YU
        default_message="Test canh bao"

        curl -s --data-urlencode "text=$@" "https://api.telegram.org/bot$token/sendMessage?chat_id=$chatid" > /dev/null
}

function repo(){
     touch /etc/apt/apt.conf.d/99verify-peer.conf
     echo >>/etc/apt/apt.conf.d/99verify-peer.conf "Acquire { https::Verify-Peer false }"
     cp /etc/apt/sources.list /etc/apt/sources.list.bka

cat << EOF > /etc/apt/sources.list
deb https://172.16.70.131/repository/u20proxy focal main restricted
deb https://172.16.70.131/repository/u20proxy focal-updates main restricted
deb https://172.16.70.131/repository/u20proxy focal universe
deb https://172.16.70.131/repository/u20proxy focal-updates universe
deb https://172.16.70.131/repository/u20proxy focal multiverse
deb https://172.16.70.131/repository/u20proxy focal-updates multiverse
deb https://172.16.70.131/repository/u20proxy focal-backports main restricted universe multiverse
deb https://172.16.70.131/repository/u20proxy focal-security main restricted
deb https://172.16.70.131/repository/u20proxy focal-security universe
deb https://172.16.70.131/repository/u20proxy focal-security multiverse
EOF

    apt clean
    apt-get update
}

sendtelegram "Setup co ban tren node `hostname`"
sendtelegram "Khai bao repo node `hostname`"
repo

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/.*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hcdadmin\nhcdadmin" | passwd root >/dev/null 2>&1

# Install package
echo "[TASK 3] Install package"
apt update -qq -y >/dev/null 2>&1
apt dist-upgrade -y -qq -y >/dev/null 2>&1
apt install -qq -y net-tools git curl vim byobu crudini >/dev/null 2>&1

echo "[TASK 4] Config timezone"
timedatectl set-timezone Asia/Ho_Chi_Minh

echo "[TASK 5] Install Iptables"
apt-get install iptables -y  >/dev/null 2>&1
apt-get install arptables -y  >/dev/null 2>&1
apt-get install ebtables -y  >/dev/null 2>&1

# update-alternatives --set iptables /usr/sbin/iptables-legacy || true
# update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy || true
# update-alternatives --set arptables /usr/sbin/arptables-legacy || true
# update-alternatives --set ebtables /usr/sbin/ebtables-legacy || true

cat > /etc/sysctl.conf << EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
EOF

sysctl -p /etc/sysctl.conf

TIME_END=`date +%s.%N`
TIME_TOTAL_TEMP=$( echo "$TIME_END - $TIME_START" | bc -l )
TIME_TOTAL=$(cut -c-4 <<< "$TIME_TOTAL_TEMP")


echo "Da hoan thanh script $0, thoi gian thuc hien:  $DATE_EXEC"
echo "Tong thoi gian thuc hien $0: $TIME_TOTAL giay"

sendtelegram "Da hoan thanh script $0, thoi gian thuc hien:  $DATE_EXEC"
sendtelegram "Tong thoi gian thuc hien script $0: $TIME_TOTAL giay"
notify
