variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "aws_keyname" {
  description = "AWS keypair name"
  type        = string
}

variable "aws_environment" {
  description = "Environment"
  type        = string
}

variable "aws_project" {
  description = "Project"
  type        = string
}

variable "aws_owner" {
  description = "Owner"
  type        = string
}

variable "aws_vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block                   = string,
    enable_dns_support           = bool,
    enable_dns_hostnames         = bool,
    public_subnets_cidr          = list(string),
    private_subnets_cidr         = list(string),
    number_of_availability_zones = number,
    enable_nat_gateway           = bool
  })
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = ""
}

# Variable for instance types and EBS sizes
variable "gateway_instance_type" {
  description = "Gateway instance type"
  type        = string
  default     = "t2.micro"
}

variable "gateway_ebs_size" {
  description = "Gateway EBS size"
  type        = number
  default     = 8
}
variable "database_server_instance_type" {
  description = "Database server instance type"
  type        = string
  default     = "t2.micro"
}

variable "database_server_ebs_size" {
  description = "Database server EBS size"
  type        = number
  default     = 8
}

variable "storage_server_instance_type" {
  description = "Storage server instance type"
  type        = string
  default     = "t2.micro"
}

variable "storage_server_ebs_size" {
  description = "Storage server EBS size"
  type        = number
  default     = 8
}

variable "mlflow_server_instance_type" {
  description = "MLflow server instance type"
  type        = string
  default     = "t2.micro"
}

variable "mlflow_server_ebs_size" {
  description = "MLflow server EBS size"
  type        = number
  default     = 8
}

# variable "infer_servers_instance_type" {
#   type        = string
#   default     = "t2.micro"
# }

# variable "infer_servers_ebs_size" {
#   description = "Security servers EBS size"
#   type        = number
#   default     = 20
# }

# Variable for EKS service CIDR block
variable "service_ipv4_cidr" {
  description = "CIDR block for the service network"
  type        = string
  default     = "172.20.0.0/16"
}

variable "node_group_min_size" {
  description = "Node group minimum size"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Node group maximum size"
  type        = number
  default     = 1
}

variable "node_group_desired_size" {
  description = "Node group desired size"
  type        = number
  default     = 1
}

# Variable for Cloudflare API token and zone ID
variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the Cloudflare DNS records"
  type        = string
  default     = "th1enlm02.live"
}