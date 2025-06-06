resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "ecs_key" {
  key_name   = "${terraform.workspace}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}
# Create VPC with public and private subnets
module "vpc" {
  source = "./modules/vpc"

  name = var.aws_project

  cidr                 = var.aws_vpc_config.cidr_block
  enable_dns_hostnames = var.aws_vpc_config.enable_dns_hostnames
  enable_dns_support   = var.aws_vpc_config.enable_dns_support
  public_subnets       = var.aws_vpc_config.public_subnets_cidr
  private_subnets      = var.aws_vpc_config.private_subnets_cidr
  azs                  = local.selected_azs
  gateway_instance     = module.instances.network_interfaces["${var.aws_project}-gateway"]
}

module "instances" {
  source = "./modules/instance"

  subnet_id = module.vpc.private_subnets_id[2]
  security_groups = [module.servers_sg.id]
  key_name = aws_key_pair.ecs_key.key_name
  ami = local.ec2_ami
  instance_type = "t2.micro"
  ebs_size = 8
  instances = [
    {
      name = "${var.aws_project}-gateway"
      private_ips = local.gateway_private_ips
      subnet_id = module.vpc.public_subnets_id[0]
      source_dest_check = false
      user_data = templatefile("${path.root}/scripts/bastion-init.sh", {
        authorized_keys_content = file("${path.root}/authorized_keys.tpl")
        private_key_content = tls_private_key.ssh_key.private_key_pem
      })
      instance_type = var.bastion_host_instance_type
      ebs_size = var.bastion_host_ebs_size
      security_groups = [module.gateway_sg.id]
    },
    {
      name = "${var.aws_project}-storage-servers"
      private_ips = local.storage_servers_ips
      instance_type = var.storage_servers_instance_type
      ebs_size = var.storage_servers_ebs_size
    },
    {
      name = "${var.aws_project}-registry-servers"
      private_ips = local.registry_servers_ips
      instance_type = var.registry_servers_instance_type
      ebs_size = var.registry_servers_ebs_size
    },
    {
      name = "${var.aws_project}-infer-servers"
      private_ips = local.infer_servers_ips
      instance_type = var.infer_servers_instance_type
      ebs_size = var.infer_servers_ebs_size
      # user_data = templatefile("${path.root}/scripts/infer-setup/user_data_training.tpl", {
      #   authorized_keys_content = file("${path.root}/authorized_keys.tpl")
      #   docker_compose_content  = file("${path.root}/scripts/infer-setup/docker-compose.yml")
      #   env_content             = file("${path.root}/.env")
      #   dockerfile_content      = file("${path.root}/scripts/infer-setup/Dockerfile")
      #   requirements_content    = file("${path.root}/scripts/infer-setup/requirements.txt")
      #   wait_for_it_content     = file("${path.root}/scripts/infer-setup/wait-for-it.sh")
      #   start_sh_content        = file("${path.root}/scripts/infer-setup/start.sh")
      # })
        security_groups = [module.infer_sg.id]
    },
  ]
}

# module "EKS" {
#   source = "./modules/eks"
#
#   name = var.aws_project
#   role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
#   k8s_version = "1.29"
#   cluster_vpc_cidr = var.aws_vpc_config.cidr_block
#   cluster_subnet_ids = module.vpc.private_subnets_id
#   service_ipv4_cidr = var.service_ipv4_cidr
#   eks_addons = ["vpc-cni", "kube-proxy", "coredns"]
#   node_group_subnet_ids = module.vpc.private_subnets_id
#   node_group_min_size = var.node_group_min_size
#   node_group_max_size = var.node_group_max_size
#   node_group_desired_size = var.node_group_desired_size
# }

module "cloudflare_dns" {
  source = "./modules/cloudflare"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id

  subdomain_mappings = {
    "mlflow2.${var.domain_name}" = {
      target_ip = module.instances.instances["${var.aws_project}-gateway"].public_ip
      proxied   = true
    }
    "inference.${var.domain_name}" = {
      target_ip = module.instances.instances["${var.aws_project}-gateway"].public_ip
      proxied   = true
    }
    "minio.${var.domain_name}" = {
      target_ip = module.instances.instances["${var.aws_project}-gateway"].public_ip
      proxied   = true
    }
    "harbor.${var.domain_name}" = {
      target_ip = module.instances.instances["${var.aws_project}-gateway"].public_ip
      proxied   = true
    }
  }

  default_ttl     = 1
  default_proxied = false
}