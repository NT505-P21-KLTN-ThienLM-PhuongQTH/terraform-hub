variable "key_name" {
  description = "SSH key pair name"
}

variable "subnet_id" {
  description = "ID của subnet để khởi tạo EC2"
}

variable "security_group_id" {
  description = "ID của security group"
}

variable "inference_server_ip" {
  description = "IP của inference server"
}

variable "ami_id" {
  description = "AMI ID cho EC2 instance"
}