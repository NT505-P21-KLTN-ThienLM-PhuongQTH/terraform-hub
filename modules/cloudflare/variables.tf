# cloudflare/variables.tf
variable "cloudflare_zone_id" {
  description = "ID của zone Cloudflare (domain chính)"
  type        = string
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
