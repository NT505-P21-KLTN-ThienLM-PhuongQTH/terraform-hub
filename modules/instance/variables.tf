variable "instances" {
  description = "List of instances to create"
  type        = list(object({
    name            = string
    subnet_id       = optional(string)
    private_ips     = list(string)
    source_dest_check = optional(bool)
    ami             = optional(string)
    instance_type   = optional(string)
    security_groups = optional(list(string))
    key_name        = optional(string)
    user_data       = optional(string)
    ebs_size        = optional(number)
  }))
}

variable "subnet_id" {
  description = "The subnet ID"
  type        = string
}

variable "security_groups" {
  description = "The security groups"
  type        = list(string)
}

variable "ami" {
  description = "The AMI of the gateway"
  type        = string
}

variable "instance_type" {
  description = "The instance type of the gateway"
  type        = string
}

variable "key_name" {
  description = "The key name to use for the gateway"
  type        = string
}

variable "ebs_size" {
  description = "The size of the EBS volume"
  type        = number
}