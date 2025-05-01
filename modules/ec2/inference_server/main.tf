module "inference_server" {
  source = "../compute"

  ami_id           = var.ami_id
  instance_type    = "t3.small"             # 2vCPU, 2GB RAM
  key_name         = var.key_name
  subnet_id        = var.subnet_id
  security_group_id = var.security_group_id
  instance_name    = "mlops-inference-server"

  user_data = templatefile("${path.module}/templates/user_data_inference.tpl", {
    authorized_keys_content = file("${path.root}/authorized_keys.tpl")
    docker_image = "YOUR_ACCOUNT_ID.dkr.ecr.${var.aws_region}.amazonaws.com/mlops-model-inference:latest",
    mlflow_tracking_uri = var.mlflow_tracking_uri
  })
}

