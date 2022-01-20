#!/bin/bash
#Author HOC CHU DONG
DATE_EXEC="$(date "+%d/%m/%Y %H:%M")"
TIME_START=`date +%s.%N`

source function.sh
source config.cfg

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
    apt-get clean
    apt-get update
}

function install_ntp(){
  sed -i 's/#NTP=/NTP=172.16.70.12/g' /etc/systemd/timesyncd.conf
  timedatectl set-ntp off
  timedatectl set-ntp on
  timedatectl timesync-status
}

function install_ops_packages () {
	echocolor "Install OpenStack client"
	sleep 3
	sudo apt-get install software-properties-common -y 2>&1 | tee -a filelog-install.txt
  sudo add-apt-repository cloud-archive:wallaby -y 2>&1 | tee -a filelog-install.txt
  sudo echo "deb http://172.16.70.131:8081/repository/u20wallaby/ focal-updates/wallaby main" > /etc/apt/sources.list.d/cloudarchive-wallaby.list
  
  sudo apt-get update -y 2>&1 | tee -a filelog-install.txt
  sudo apt-get upgrade -y 2>&1 | tee -a filelog-install.txt
  sudo apt-get install python3-openstackclient -y 2>&1 | tee -a filelog-install.txt
  
  systemctl disable ufw
  systemctl stop ufw
}

##############
repo
install_ntp
install_ops_packages
