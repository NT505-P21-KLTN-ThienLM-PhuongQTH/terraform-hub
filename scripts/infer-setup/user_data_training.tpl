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

# Tạo thư mục cấu hình
mkdir -p /home/ubuntu/mlops/training
chown -R ubuntu:ubuntu /home/ubuntu/mlops

# Tạo thư mục dữ liệu
mkdir -p /home/ubuntu/mlops/training/airflow/dags
mkdir -p /home/ubuntu/mlops/training/airflow/logs
mkdir -p /home/ubuntu/mlops/training/airflow/plugins
mkdir -p /home/ubuntu/mlops/training/mlflow
chown -R ubuntu:ubuntu /home/ubuntu/mlops
sudo chown -R ubuntu:ubuntu /home/ubuntu/mlops/training

# Sao chép các file cấu hình
cat > /home/ubuntu/mlops/training/docker-compose.yml << 'EOF'
${docker_compose_content}
EOF

cat > /home/ubuntu/mlops/training/.env << 'EOF'
${env_content}
EOF

cat > /home/ubuntu/mlops/training/mlflow/Dockerfile << 'EOF'
${dockerfile_content}
EOF

cat > /home/ubuntu/mlops/training/mlflow/requirements.txt << 'EOF'
${requirements_content}
EOF

cat > /home/ubuntu/mlops/training/wait-for-it.sh << 'EOF'
${wait_for_it_content}
EOF

# Tạo script khởi động
cat > /home/ubuntu/mlops/training/start.sh << 'SCRIPT'
${start_sh_content}
SCRIPT

# Cấp quyền thực thi cho wait-for-it.sh
sudo chmod +x /home/ubuntu/mlops/training/wait-for-it.sh
sudo chmod +x /home/ubuntu/mlops/training/start.sh

sudo -u ubuntu bash /home/ubuntu/mlops/training/start.sh