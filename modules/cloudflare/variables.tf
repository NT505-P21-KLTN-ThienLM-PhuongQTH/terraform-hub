# cloudflare/variables.tf
variable "cloudflare_zone_id" {
  description = "ID của zone Cloudflare (domain chính)"
  type        = string
}

variable "subdomain" {
  description = "Tên subdomain (không bao gồm domain chính)"
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

variable "cloudflare_api_token" {
  description = "API token của Cloudflare"
  type        = string
}


variable "subdomain_mappings" {
  description = "Map of subdomain to target configuration"
  type = map(object({
    target_ip = string
    ttl       = optional(number)
    proxied   = optional(bool)
  }))
}

variable "default_ttl" {
  description = "Default TTL for DNS records"
  type        = number
  default     = 1
}

variable "default_proxied" {
  description = "Default proxy setting for DNS records"
  type        = bool
  default     = false
}
