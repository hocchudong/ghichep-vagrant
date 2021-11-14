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

sendtelegram "Thuc hien script $0 tren `hostname`"
sendtelegram "Setup co ban tren node `hostname`"

echo "[TASK 1]Khai bao repo node `hostname`"

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
# apt dist-upgrade -y -qq -y >/dev/null 2>&1
apt install -qq -y net-tools >/dev/null 2>&1
apt install -qq -y python3-dev libffi-dev gcc libssl-dev  >/dev/null 2>&1

apt install -qq -y python3-pip >/dev/null 2>&1
pip3 install -U pip  >/dev/null 2>&1

echo "[TASK 4] Config timezone"
timedatectl set-timezone Asia/Ho_Chi_Minh

echo "[TASK 5] Install Iptables"
apt-get install iptables -y  >/dev/null 2>&1
apt-get install arptables -y  >/dev/null 2>&1
apt-get install ebtables -y  >/dev/null 2>&1

update-alternatives --set iptables /usr/sbin/iptables-legacy || true
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy || true
update-alternatives --set arptables /usr/sbin/arptables-legacy || true
update-alternatives --set ebtables /usr/sbin/ebtables-legacy || true

sendtelegram "Da cai dat xong Ubuntu co ban"
notify