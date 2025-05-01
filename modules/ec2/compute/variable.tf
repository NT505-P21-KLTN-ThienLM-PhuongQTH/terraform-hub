variable "ami_id" {
  description = "AMI ID cho EC2 instance (Amazon Linux 2 ARM64 mặc định)"
  default     = "ami-0e6b56ad0d51a4b2f" # Amazon Linux 2 ARM64 cho us-east-1
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t4g.small"  # ARM-based instance cho tiết kiệm chi phí
}

variable "key_name" {
  description = "SSH key pair name"
}

variable "subnet_id" {
  description = "ID của subnet để khởi tạo EC2"
}

variable "security_group_id" {
  description = "ID của security group"
}

variable "instance_name" {
  description = "Tên cho EC2 instance"
}

variable "user_data" {
  description = "User data script"
  default     = ""
}