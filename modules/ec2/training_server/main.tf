
module "training_server" {
  source = "../compute"

  ami_id           = var.ami_id
  instance_type    = "t3.medium"
  key_name         = var.key_name
  subnet_id        = var.subnet_id
  security_group_id = var.security_group_id
  instance_name    = "mlops-training-server"

  user_data = templatefile("${path.module}/templates/user_data_training.tpl", {
    authorized_keys_content = file("${path.root}/authorized_keys.tpl")
    docker_compose_content = file("${path.module}/templates/docker-compose.yml")
    env_content            = file("${path.root}/.env")
    dockerfile_content     = file("${path.module}/templates/Dockerfile")
    requirements_content   = file("${path.module}/templates/requirements.txt")
    wait_for_it_content    = file("${path.module}/templates/wait-for-it.sh")
    start_sh_content       = file("${path.module}/templates/start.sh")
  })
}