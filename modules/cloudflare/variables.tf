# cloudflare/variables.tf
variable "cloudflare_zone_id" {
  description = "ID của zone Cloudflare (domain chính)"
  type        = string
}

variable "subdomain" {
  description = "Tên subdomain (không bao gồm domain chính)"
  type        = string
}

variable "ec2_instance_id" {
  description = "ID của EC2 instance"
  type        = string
}

variable "use_elastic_ip" {
  description = "Sử dụng Elastic IP thay vì public IP của EC2"
  type        = bool
  default     = false
}

variable "elastic_ip" {
  description = "Elastic IP address nếu sử dụng"
  type        = string
  default     = ""
}

variable "ttl" {
  description = "TTL cho DNS record (1 cho auto)"
  type        = number
  default     = 1
}

variable "enable_proxy" {
  description = "Bật proxy Cloudflare cho subdomain"
  type        = bool
  default     = true
}

variable "cloudflare_api_token" {
  description = "API token của Cloudflare"
  type        = string
}