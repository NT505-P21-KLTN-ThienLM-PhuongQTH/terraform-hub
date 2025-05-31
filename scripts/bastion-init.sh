#!/bin/bash

sudo apt update
sudo apt-get update
sudo apt install net-tools -y
sudo apt install traceroute -y
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sudo sysctl -p
# https://docs.aws.amazon.com/vpc/latest/userguide/work-with-nat-instances.html
sudo /sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo /sbin/iptables -F FORWARD
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get -y install iptables-persistent
sudo netfilter-persistent save
sudo netfilter-persistent reload
