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
mkdir -p /home/ec2-user/mlops/inference
chown -R ec2-user:ec2-user /home/ec2-user/mlops

# Tạo Kubernetes deployment cho FastAPI
cat > /home/ec2-user/mlops/inference/fastapi-deployment.yaml << 'YAML'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-inference
  labels:
    app: model-inference
spec:
  replicas: 2
  selector:
    matchLabels:
      app: model-inference
  template:
    metadata:
      labels:
        app: model-inference
    spec:
      containers:
      - name: model-inference
        image: $${DOCKER_IMAGE}
        ports:
        - containerPort: 8000
        env:
        - name: MLFLOW_TRACKING_URI
          value: $${MLFLOW_TRACKING_URI}
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
  name: model-inference
spec:
  selector:
    app: model-inference
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
YAML

# Chuẩn bị Dockerfile mẫu
cat > /home/ec2-user/mlops/inference/Dockerfile << 'DOCKERFILE'
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
DOCKERFILE

# Chuẩn bị mẫu FastAPI
cat > /home/ec2-user/mlops/inference/main.py << 'PYTHON'
from fastapi import FastAPI, HTTPException
import mlflow
import mlflow.pyfunc
import numpy as np
import os
import logging
from pydantic import BaseModel
from typing import List, Dict, Any

# Cấu hình logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Cấu hình MLflow
mlflow_tracking_uri = os.environ.get("MLFLOW_TRACKING_URI")
mlflow.set_tracking_uri(mlflow_tracking_uri)
logger.info(f"MLflow tracking URI: {mlflow_tracking_uri}")

# Định nghĩa model
model = None
model_name = os.environ.get("MODEL_NAME", "best_model")
model_stage = os.environ.get("MODEL_STAGE", "Production")

app = FastAPI(title="Model Inference API")

class PredictionInput(BaseModel):
    features: List[float]

class PredictionBatchInput(BaseModel):
    instances: List[List[float]]

@app.on_event("startup")
def load_model():
    global model
    try:
        logger.info(f"Loading model {model_name} from {mlflow_tracking_uri}")
        model_uri = f"models:/{model_name}/{model_stage}"
        model = mlflow.pyfunc.load_model(model_uri)
        logger.info("Model loaded successfully")
    except Exception as e:
        logger.error(f"Error loading model: {e}")
        model = None

@app.get("/")
def root():
    return {"message": "Model Inference API", "status": "running"}

@app.get("/health")
def health_check():
    if model is None:
        raise HTTPException(status_code=503, detail="Model not loaded")
    return {"status": "healthy"}

@app.post("/predict")
def predict(input_data: PredictionInput):
    if model is None:
        try:
            load_model()
        except Exception as e:
            raise HTTPException(status_code=503, detail=f"Model not available: {str(e)}")

    try:
        features = np.array([input_data.features])
        prediction = model.predict(features)
        return {"prediction": prediction.tolist()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction error: {str(e)}")

@app.post("/batch-predict")
def batch_predict(input_data: PredictionBatchInput):
    if model is None:
        try:
            load_model()
        except Exception as e:
            raise HTTPException(status_code=503, detail=f"Model not available: {str(e)}")

    try:
        features = np.array(input_data.instances)
        predictions = model.predict(features)
        return {"predictions": predictions.tolist()}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Batch prediction error: {str(e)}")
PYTHON

# Tạo requirements.txt
cat > /home/ec2-user/mlops/inference/requirements.txt << 'REQUIREMENTS'
fastapi==0.95.0
uvicorn==0.21.1
mlflow==2.3.1
numpy==1.24.2
scikit-learn==1.2.2
boto3==1.26.115
python-dotenv==1.0.0
REQUIREMENTS

# Tạo script khởi động
cat > /home/ec2-user/mlops/inference/deploy.sh << 'SCRIPT'
#!/bin/bash
export DOCKER_IMAGE="${docker_image}"
export MLFLOW_TRACKING_URI="${mlflow_tracking_uri}"

# Build và push Docker image
docker build -t $DOCKER_IMAGE .
docker push $DOCKER_IMAGE

# Deploy lên k3s
envsubst < fastapi-deployment.yaml | kubectl apply -f -
SCRIPT

chmod +x /home/ec2-user/mlops/inference/deploy.sh
chown -R ec2-user:ec2-user /home/ec2-user/mlops