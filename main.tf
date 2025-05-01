data "aws_ami" "amazon_linux_amd64" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ecs_key" {
  key_name   = "${terraform.workspace}-${var.app_name}-ecs-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

module "network" {
  source = "./modules/network"
}

module "common_sg" {
  source      = "./modules/security_group"
  name        = "${var.app_name}-rds"
  vpc_id      = module.network.vpc_id
  description = "Security Group for RDS"
  ingress_rules_with_cidr = [
    {
      protocol  = "tcp"
      from_port = 22
      to_port   = 22
      ip        = "0.0.0.0/0"
    },
    {
      protocol  = "tcp"
      from_port = 80
      to_port   = 80
      ip        = "0.0.0.0/0"
    },
    {
      protocol  = "tcp"
      from_port = 443
      to_port   = 443
      ip        = "0.0.0.0/0"
    },
    {
      protocol    = "tcp"
      from_port   = 6443
      to_port     = 6443
      ip          = "0.0.0.0/0"
      description = "Kubernetes API"
    },
    {
      protocol    = "tcp"
      from_port   = 5000
      to_port     = 5000
      ip          = "0.0.0.0/0"
      description = "MLflow UI"
    },
    {
      protocol  = "tcp"
      from_port = 9000
      to_port   = 9000
      ip        = "0.0.0.0/0"
    },
    {
      protocol    = "tcp"
      from_port   = 8080
      to_port     = 8080
      ip          = "0.0.0.0/0"
      description = "Airflow UI"
    },
  ]
  egress_rules_with_cidr = [
    {
      protocol = "-1"
      ip       = "0.0.0.0/0"
    }
  ]
}

module "training_server" {
  source = "./modules/ec2/training_server"

  key_name          = aws_key_pair.ecs_key.key_name
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.common_sg.id
  aws_region        = var.aws_region
  ami_id            = data.aws_ami.amazon_linux_amd64.id
}

# module "inference_server" {
#   source = "./modules/ec2/inference_server"
#
#   key_name         = aws_key_pair.ecs_key.key_name
#   subnet_id        = module.network.public_subnet_id
#   security_group_id = module.common_sg.id
#   mlflow_tracking_uri = "http://${module.training_server.training_server_ip}:5000"
#   aws_region = var.aws_region
#   ami_id = data.aws_ami.amazon_linux_amd64.id
# }

# module "monitoring_server" {
#   source = "./modules/ec2/monitoring_server"
#
#   key_name         = aws_key_pair.ecs_key.key_name
#   subnet_id        = module.network.public_subnet_id
#   security_group_id = module.common_sg.id
#   inference_server_ip = module.inference_server.inference_server_ip
#   ami_id = data.aws_ami.amazon_linux_arm64.id
# }

module "subdomain_for_ec2" {
  source = "./modules/cloudflare"

  subdomain          = "stag.mlflow"
  ec2_instance_id    = module.training_server.instance_id
  enable_proxy       = false
  ttl                = 1
  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id = var.cloudflare_zone_id
}