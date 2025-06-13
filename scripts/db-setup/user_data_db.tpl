#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker $USER

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

sudo chmod +x /home/ubuntu/start.sh
sudo bash /home/ubuntu/start.sh
