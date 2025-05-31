#!/bin/bash

# Config SSH
mkdir -p /home/ec2-user/.ssh
cat <<EOF > /home/ec2-user/.ssh/authorized_keys
${authorized_keys_content}
EOF

# Cài đặt Docker
yum update -y
amazon-linux-extras install docker -y
service docker start
systemctl enable docker
usermod -a -G docker ec2-user

# Cài đặt Docker Compose plugin (phiên bản 2)
mkdir -p /home/ec2-user/.docker/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-linux-x86_64 \
  -o /home/ec2-user/.docker/cli-plugins/docker-compose
chmod +x /home/ec2-user/.docker/cli-plugins/docker-compose
chown -R ec2-user:ec2-user /home/ec2-user/.docker

# Tạo thư mục cấu hình
mkdir -p /home/ec2-user/mlops/training
chown -R ec2-user:ec2-user /home/ec2-user/mlops

# Tạo thư mục dữ liệu
mkdir -p /home/ec2-user/mlops/training/airflow/dags
mkdir -p /home/ec2-user/mlops/training/airflow/logs
mkdir -p /home/ec2-user/mlops/training/airflow/plugins
mkdir -p /home/ec2-user/mlops/training/mlflow
chown -R ec2-user:ec2-user /home/ec2-user/mlops
sudo chown -R ec2-user:ec2-user /home/ec2-user/mlops/training

# Sao chép các file cấu hình
cat > /home/ec2-user/mlops/training/docker-compose.yml << 'EOF'
${docker_compose_content}
EOF

cat > /home/ec2-user/mlops/training/.env << 'EOF'
${env_content}
EOF

cat > /home/ec2-user/mlops/training/mlflow/Dockerfile << 'EOF'
${dockerfile_content}
EOF

cat > /home/ec2-user/mlops/training/mlflow/requirements.txt << 'EOF'
${requirements_content}
EOF

cat > /home/ec2-user/mlops/training/wait-for-it.sh << 'EOF'
${wait_for_it_content}
EOF

# Tạo script khởi động
cat > /home/ec2-user/mlops/training/start.sh << 'SCRIPT'
${start_sh_content}
SCRIPT

# Cấp quyền thực thi cho wait-for-it.sh
sudo chmod +x /home/ec2-user/mlops/training/wait-for-it.sh
sudo chmod +x /home/ec2-user/mlops/training/start.sh

sudo -u ec2-user bash /home/ec2-user/mlops/training/start.sh