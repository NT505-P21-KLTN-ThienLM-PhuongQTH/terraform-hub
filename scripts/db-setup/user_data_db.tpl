#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Cho phép tự động restart service mà không hỏi
sudo apt install -y needrestart
echo "\$nrconf{restart} = 'a';" | sudo tee /etc/needrestart/conf.d/restart.conf > /dev/null

sudo apt update -y
sudo apt upgrade -y

# Cài đặt Docker
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Xóa file GPG nếu tồn tại
sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Cài đặt Docker Compose plugin (v2)
mkdir -p /home/ubuntu/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 \
  -o /home/ubuntu/.docker/cli-plugins/docker-compose
chmod +x /home/ubuntu/.docker/cli-plugins/docker-compose
chown -R ubuntu:ubuntu /home/ubuntu/.docker

# Copy configuration files
cat > /home/ubuntu/docker-compose.yml << 'EOF'
${docker_compose_content}
EOF

cat > /home/ubuntu/.env << 'EOF'
${env_content}
EOF

cat > /home/ubuntu/start.sh << 'SCRIPT'
${start_sh_content}
SCRIPT

sudo curl -L -o /home/ubuntu/schema.sql https://raw.githubusercontent.com/NT505-P21-KLTN-ThienLM-PhuongQTH/terraform-hub/eks/scripts/db-setup/schema.sql

sudo chmod +x /home/ubuntu/start.sh
sudo bash /home/ubuntu/start.sh
