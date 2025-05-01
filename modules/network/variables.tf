variable "vpc_cidr" {
  description = "CIDR block cho VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block cho public subnet"
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block cho private subnet"
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "AZ cho subnet"
  default     = "us-east-1a"
}