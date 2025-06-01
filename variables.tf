variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "awslab"
}

variable "aws_environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "aws_project" {
  description = "Project"
  type        = string
  default     = "CI_build_failure_prediction"
}

variable "aws_owner" {
  description = "Owner"
  type        = string
  default     = "ThienML_PhuongQTH"
}

variable "aws_vpc_config" {
  description = "VPC configuration"
  type = object({
    cidr_block                   = string,
    enable_dns_support           = bool,
    enable_dns_hostnames         = bool,
    public_subnets_cidr          = list(string),
    private_subnets_cidr         = list(string),
    number_of_availability_zones = number
  })
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = ""
}

variable "bastion_host_instance_type" {
  description = "Bastion host instance type"
  type        = string
  default     = "t2.micro"
}

variable "bastion_host_ebs_size" {
  description = "Bastion host EBS size"
  type        = number
  default     = 8
}

variable "storage_servers_instance_type" {
  description = "Storage servers instance type"
  type        = string
  default     = "t2.micro"
}

variable "storage_servers_ebs_size" {
  description = "Storage servers EBS size"
  type        = number
  default     = 8
}

variable "registry_servers_instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "registry_servers_ebs_size" {
  type        = number
  default     = 8
}

variable "infer_servers_instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "infer_servers_ebs_size" {
  description = "Security servers EBS size"
  type        = number
  default     = 20
}

variable "service_ipv4_cidr" {
  description = "CIDR block for the service network"
  type        = string
  default     = "10.0.0.0/16"
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

variable "cloudflare_api_token" {
  description = "Cloudflare API token"
  type        = string
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID"
  type        = string
}