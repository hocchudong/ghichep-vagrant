# File vagrant cài đặt devstack

# Hướng dẫn thực hiện.

## Tạo VM

## Thực hiện cài devstack

- Tạo user

```
sudo useradd -s /bin/bash -d /opt/stack -m stack

echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack

sudo chown stack:stack -R /opt/stack

sudo -u stack -i (stack 계정으로 전환하기. 그 전에는 ubuntu라는 계정으로 되어 있음)

git clone https://opendev.org/openstack/devstack

cd devstack

git checkout stable/wallaby
```