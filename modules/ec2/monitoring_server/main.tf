module "monitoring_server" {
  source = "../compute"

  ami_id           = var.ami_id
  instance_type    = "t3.small"
  key_name         = var.key_name
  subnet_id        = var.subnet_id
  security_group_id = var.security_group_id
  instance_name    = "mlops-monitoring-server"

  user_data = templatefile("${path.module}/templates/user_data_monitoring.tpl", {
    authorized_keys_content = file("${path.root}/authorized_keys.tpl")
    inference_ip = var.inference_server_ip
  })
}

