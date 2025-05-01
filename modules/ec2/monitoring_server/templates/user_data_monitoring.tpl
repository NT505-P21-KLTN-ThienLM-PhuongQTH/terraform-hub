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

# Cài đặt k3s
curl -sfL https://get.k3s.io | sh -
mkdir -p /home/ec2-user/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ec2-user/.kube/config
chmod 644 /home/ec2-user/.kube/config
chown -R ec2-user:ec2-user /home/ec2-user/.kube

# Cài đặt kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Tạo thư mục cấu hình
mkdir -p /home/ec2-user/mlops/monitoring
chown -R ec2-user:ec2-user /home/ec2-user/mlops

# Cấu hình Prometheus
cat > /home/ec2-user/mlops/monitoring/prometheus-config.yaml << 'YAML'
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
    scrape_configs:
      - job_name: 'prometheus'
        static_configs:
          - targets: ['localhost:9090']
      - job_name: 'inference-service'
        metrics_path: /metrics
        static_configs:
          - targets: ['${INFERENCE_IP}:80']
      - job_name: 'node-exporter'
        static_configs:
          - targets: ['${INFERENCE_IP}:9100']
YAML

# Deployment cho Prometheus
cat > /home/ec2-user/mlops/monitoring/prometheus-deployment.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
  labels:
    app: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
      - name: prometheus
        image: prom/prometheus:v2.44.0
        ports:
        - containerPort: 9090
        volumeMounts:
        - name: config-volume
          mountPath: /etc/prometheus
        - name: storage-volume
          mountPath: /prometheus
        args:
        - "--config.file=/etc/prometheus/prometheus.yml"
        - "--storage.tsdb.path=/prometheus"
        - "--web.console.libraries=/usr/share/prometheus/console_libraries"
        - "--web.console.templates=/usr/share/prometheus/consoles"
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
      volumes:
      - name: config-volume
        configMap:
          name: prometheus-config
      - name: storage-volume
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  selector:
    app: prometheus
  ports:
  - port: 9090
    targetPort: 9090
  type: LoadBalancer
YAML

# Cấu hình Grafana
cat > /home/ec2-user/mlops/monitoring/grafana-deployment.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
  labels:
    app: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:9.5.1
        ports:
        - containerPort: 3000
        env:
        - name: GF_SECURITY_ADMIN_PASSWORD
          value: "adminpassword"
        - name: GF_AUTH_ANONYMOUS_ENABLED
          value: "true"
        resources:
          limits:
            memory: "512Mi"
            cpu: "500m"
          requests:
            memory: "256Mi"
            cpu: "250m"
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  selector:
    app: grafana
  ports:
  - port: 3000
    targetPort: 3000
  type: LoadBalancer
YAML

# Tạo Node Exporter DaemonSet để thu thập metrics từ các node
cat > /home/ec2-user/mlops/monitoring/node-exporter-daemonset.yaml << 'YAML'
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-exporter
  labels:
    app: node-exporter
spec:
  selector:
    matchLabels:
      app: node-exporter
  template:
    metadata:
      labels:
        app: node-exporter
    spec:
      hostNetwork: true
      hostPID: true
      containers:
      - name: node-exporter
        image: prom/node-exporter:v1.5.0
        args:
        - "--path.procfs=/host/proc"
        - "--path.sysfs=/host/sys"
        - "--collector.filesystem.ignored-mount-points=^/(dev|proc|sys|var/lib/docker/.+)($|/)"
        ports:
        - containerPort: 9100
          hostPort: 9100
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
        - name: sys
          mountPath: /host/sys
          readOnly: true
        - name: root
          mountPath: /rootfs
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
      - name: sys
        hostPath:
          path: /sys
      - name: root
        hostPath:
          path: /
YAML

# Tạo script khởi động
cat > /home/ec2-user/mlops/monitoring/deploy.sh << 'SCRIPT'
#!/bin/bash
export INFERENCE_IP=${inference_ip}

# Deploy Prometheus
envsubst < prometheus-config.yaml | kubectl apply -f -
kubectl apply -f prometheus-deployment.yaml

# Deploy Grafana
kubectl apply -f grafana-deployment.yaml

# Deploy Node Exporter
kubectl apply -f node-exporter-daemonset.yaml
SCRIPT

chmod +x /home/ec2-user/mlops/monitoring/deploy.sh
chown -R ec2-user:ec2-user /home/ec2-user/mlops
