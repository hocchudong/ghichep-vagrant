# File vagrant cài đặt devstack

# Hướng dẫn thực hiện.

## Tạo VM

- Tạo VM Ubuntu20.04
- Khai báo thêm các cấu hình sau

	```
	sudo useradd -s /bin/bash -d /opt/stack -m stack

  sudo su
  apt-get install sudo -y || yum install -y sudo
  echo "stack ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

	apt-get update -y
	apt-get upgrade -y
	apt-get install iptables -y
	apt-get install arptables -y
	apt-get install ebtables -y

	update-alternatives --set iptables /usr/sbin/iptables-legacy || true
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy || true
	update-alternatives --set arptables /usr/sbin/arptables-legacy || true
	update-alternatives --set ebtables /usr/sbin/ebtables-legacy || true
	
	sudo apt remove python3-simplejson -y 

  sudo apt remove python3-pyasn1-modules -y 
	```

## Thực hiện cài devstack

- 

- Tạo user

	```
	sudo useradd -s /bin/bash -d /opt/stack -m stack
	echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
	sudo chown stack:stack -R /opt/stack
	sudo -u stack -i
	```

- Tải devstack

	```
	git clone https://opendev.org/openstack/devstack

	cd devstack

	git checkout stable/wallaby
	```
	
- Tạo file local.conf

	```

	[[local|localrc]]
	HOST_IP=172.16.70.188
	FORCE=yes
	ADMIN_PASSWORD=Welcome123
	DATABASE_PASSWORD=$ADMIN_PASSWORD
	RABBIT_PASSWORD=$ADMIN_PASSWORD
	SERVICE_PASSWORD=$ADMIN_PASSWORD

	disable_service etcd3

	## Neutron options
	Q_USE_SECGROUP=True
	FLOATING_RANGE="172.16.16.0/24"
	IPV4_ADDRS_SAFE_TO_USE="10.0.0.0/22"
	Q_FLOATING_ALLOCATION_POOL=start=172.16.16.150,end=172.16.16.200
	PUBLIC_NETWORK_GATEWAY="172.16.16.1"
	PUBLIC_INTERFACE=eth1
	IP_VERSION=4


	# Open vSwitch provider networking configuration
	Q_USE_PROVIDERNET_FOR_PUBLIC=True
	OVS_PHYSICAL_BRIDGE=br-ex
	PUBLIC_BRIDGE=br-ex
	OVS_BRIDGE_MAPPINGS=public:br-ex

	Q_ASSIGN_GATEWAY_TO_PUBLIC_BRIDGE=FALSE

	# End of external network configuration

  disable_service tempest

	### Tuy chinh cau hinh cho neutron
	[[post-config|/etc/neutron/dhcp_agent.ini]]
	[DEFAULT]
	enable_isolated_metadata = True

	```
----

## Lưu ý

- Gỡ các gói trên ubuntu 20.04

```
sudo apt remove python3-simplejson -y 

sudo apt remove python3-pyasn1-modules -y 
```

Note