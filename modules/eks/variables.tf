variable "name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "role_arn" {
  description = "The ARN of the IAM role to use for the EKS cluster"
  type        = string
}

variable "k8s_version" {
  description = "The Kubernetes version to use for the EKS cluster"
  type        = string
}

variable "cluster_vpc_cidr" {
  description = "The CIDR block to use for the EKS cluster VPC"
  type        = string
}

variable "cluster_subnet_ids" {
  description = "The subnet IDs to use for the EKS cluster"
  type        = list(string)
}

variable "service_ipv4_cidr" {
  description = "The CIDR block to use for the Kubernetes service IPs"
  type        = string
}

variable "eks_addons" {
  description = "The list of EKS addons to enable"
  type        = list(string)
}

variable "node_group_subnet_ids" {
  description = "The subnet IDs to use for the EKS node group"
  type        = list(string)
}


variable "node_group_desired_size" {
  description = "The desired number of nodes in the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "The maximum number of nodes in the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "The minimum number of nodes in the EKS node group"
  type        = number
}
