variable "name" {
  description = "Name for the autoscaling group"
  type    = string
}

variable "aws_key_name" {
  description = "AWS key pair name"
  type    = string
}

variable "ami" {
  description = "AMI ID for the EC2 instances"
  type    = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type    = string
  default  = "t2.micro"
}

variable "user_data" {
  description = "User data for the EC2 instances"
  type    = string
}

variable "ec2_subnets" {
  description = "Subnet IDs for the EC2 instances"
  type    = list(string)
}

variable "ec2_security_groups" {
  description = "Security group names for the EC2 instances"
  type    = list(string)
  default = []
}

variable "min_size" {
  description = "Minimum number of instances in the autoscaling group"
  type    = number
}

variable "max_size" {
  description = "Maximum number of instances in the autoscaling group"
  type    = number
}

variable "desired_capacity" {
  description = "Desired number of instances in the autoscaling group"
  type    = number
}

variable "lb_security_groups" {
  description = "Security group names for the load balancer"
  type    = list(string)
}

variable "lb_subnets" {
  description = "Subnet IDs for the load balancer"
  type    = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type    = string
}

variable "health_check" {
  description = "Health check for the autoscaling group"
  type    = object({
    path = string
    port = number
    protocol = string
  })
}