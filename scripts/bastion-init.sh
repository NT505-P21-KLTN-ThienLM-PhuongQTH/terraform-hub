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

mkdir -p /home/ubuntu/.ssh
cat <<EOF > /home/ubuntu/.ssh/authorized_keys
${authorized_keys_content}
EOF

# HAProxy setup
sudo apt install haproxy -y
sudo systemctl start haproxy
sudo systemctl enable haproxy
sudo apt install net-tools -y
sudo mkdir -p /etc/haproxy/certs
chmod 600 /etc/haproxy/certs

# Install Certbot
echo "Installing Certbot..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y certbot python3-certbot-nginx

# Install OpenVPN
sudo curl -L -o /home/ubuntu/openvpn-install.sh https://raw.githubusercontent.com/NT505-P21-KLTN-ThienLM-PhuongQTH/terraform-hub/eks/scripts/openvpn-install.sh
chmod +x /home/ubuntu/openvpn-install.sh

# Stop Nginx if it's running
if systemctl is-active --quiet nginx; then
    echo "Stopping Nginx..."
    sudo systemctl stop nginx
fi
