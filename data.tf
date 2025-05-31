data "aws_caller_identity" "current" {}

# List all avalability zones in the region
data "aws_availability_zones" "available" {}

# Get Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  selected_azs        = slice(data.aws_availability_zones.available.names, 0, var.aws_vpc_config.number_of_availability_zones)
  ec2_ami             = var.ami != "" ? var.ami : data.aws_ami.ubuntu.id
  gateway_private_ips = [cidrhost(module.vpc.public_subnets_cidr[0], 10)]
  storage_servers_ips = [cidrhost(module.vpc.private_subnets_cidr[2], 10)]
  infer_servers_ips   = [cidrhost(module.vpc.private_subnets_cidr[2], 11)]
}
