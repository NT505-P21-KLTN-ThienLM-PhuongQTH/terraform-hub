variable "key_name" {
  description = "SSH key pair name"
}

variable "subnet_id" {
  description = "ID của subnet để khởi tạo EC2"
}

variable "security_group_id" {
  description = "ID của security group"
}

variable "aws_region" {
  description = "Tên region AWS"
}

variable "ami_id" {
  description = "AMI ID cho EC2 instance"
}