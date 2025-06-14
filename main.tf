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
  enable_nat_gateway   = var.aws_vpc_config.enable_nat_gateway
  gateway_instance     = module.instances.network_interfaces["${var.aws_project}-gateway"]
  map_public_ip_on_launch = true
}

module "instances" {
  source = "./modules/instance"

  subnet_id = module.vpc.public_subnets_id[0]
  security_groups = [module.default_sg.id]
  key_name = var.aws_keyname
  ami = local.ec2_ami
  instance_type = "t2.micro"
  ebs_size = 8
  instances = [
    {
      name = "${var.aws_project}-gateway"
      private_ips = local.gateway_ips
      subnet_id = module.vpc.public_subnets_id[0]
      source_dest_check = false
      user_data = templatefile("${path.root}/scripts/bastion-init.sh", {
        authorized_keys_content = file("${path.root}/authorized_keys.tpl")
      })
      instance_type = var.gateway_instance_type
      ebs_size = var.gateway_ebs_size
      security_groups = [module.gateway_sg.id]
    },
    {
      name = "${var.aws_project}-database-servers"
      private_ips = local.database_server_ips
      subnet_id = module.vpc.private_subnets_id[0]
      instance_type = var.database_server_instance_type
      ebs_size = var.database_server_ebs_size
      security_groups = [module.database_sg.id]
      user_data = templatefile("${path.root}/scripts/db-setup/user_data_db.tpl", {
        docker_compose_content  = file("${path.root}/scripts/db-setup/docker-compose.yml")
        env_content             = file("${path.root}/scripts/db-setup/.env")
        # schema_content          = file("${path.root}/scripts/db-setup/schema.sql")
        start_sh_content        = file("${path.root}/scripts/db-setup/start.sh")
      })
    },
    {
      name = "${var.aws_project}-storage-servers"
      private_ips = local.storage_server_ips
      subnet_id = module.vpc.private_subnets_id[1]
      instance_type = var.storage_server_instance_type
      ebs_size = var.storage_server_ebs_size
      security_groups = [module.storage_sg.id]
      user_data = templatefile("${path.root}/scripts/storage-setup/user_data_vault.tpl", {})
    },
    {
      name = "${var.aws_project}-mlflow-server"
      private_ips = local.mlflow_server_ips
      subnet_id = module.vpc.private_subnets_id[2]
      instance_type = var.mlflow_server_instance_type
      ebs_size = var.mlflow_server_ebs_size
      security_groups = [module.mlflow_sg.id]
      user_data = templatefile("${path.root}/scripts/infer-setup/user_data_training.tpl", {
        # authorized_keys_content = file("${path.root}/authorized_keys.tpl")
        docker_compose_content  = file("${path.root}/scripts/infer-setup/docker-compose.yml")
        env_content             = file("${path.root}/scripts/infer-setup/.env")
        dockerfile_content      = file("${path.root}/scripts/infer-setup/Dockerfile")
        requirements_content    = file("${path.root}/scripts/infer-setup/requirements.txt")
        wait_for_it_content     = file("${path.root}/scripts/infer-setup/wait-for-it.sh")
        start_sh_content        = file("${path.root}/scripts/infer-setup/start.sh")
      })
    },
  ]
}

module "EKS" {
  source = "./modules/eks"

  name = var.aws_project
  role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
  k8s_version = "1.29"
  cluster_vpc_cidr = var.aws_vpc_config.cidr_block
  cluster_subnet_ids = module.vpc.private_subnets_id
  service_ipv4_cidr = var.service_ipv4_cidr
  eks_addons = ["vpc-cni", "kube-proxy", "coredns", "aws-ebs-csi-driver"]
  node_group_subnet_ids = module.vpc.private_subnets_id
  node_group_min_size = var.node_group_min_size
  node_group_max_size = var.node_group_max_size
  node_group_desired_size = var.node_group_desired_size
}

module "cloudflare_dns" {
  source = "./modules/cloudflare"

  cloudflare_api_token = var.cloudflare_api_token
  cloudflare_zone_id   = var.cloudflare_zone_id
  domain_name          = var.domain_name
  gateway_ip           = module.instances.instances["${var.aws_project}-gateway"].public_ip

  subdomain_mappings = {
    "minio.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "harbor.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "vault.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "mlflow.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "grafana.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "argocd.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "ciflow.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "app-api.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "ghtorrent-api.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "model-api.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "loki.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "prometheus.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
    "sonarqube.${var.domain_name}" = {
      ttl     = 1
      proxied = false
    }
  }

  default_ttl     = 1
  default_proxied = false

  providers = {
    cloudflare = cloudflare
  }

  depends_on = [
    module.instances,
    module.vpc
  ]
}