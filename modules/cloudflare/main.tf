# Cloudflare DNS Module
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}

# Get zone information
data "cloudflare_zone" "domain" {
  zone_id = var.cloudflare_zone_id
}

# Create A record for the root domain
resource "cloudflare_record" "root_domain" {
  # for_each = var.subdomain_mappings

  zone_id = var.cloudflare_zone_id
  name    = var.domain_name
  value   = var.gateway_ip
  type    = "A"
  ttl     = var.default_ttl
  proxied = var.default_proxied
}

# Create CNAME records for subdomains
resource "cloudflare_record" "subdomains" {
  for_each = var.subdomain_mappings

  zone_id = var.cloudflare_zone_id
  name    = each.key
  value   = var.domain_name
  type    = "CNAME"
  ttl     = each.value.ttl != null ? each.value.ttl : var.default_ttl
  proxied = each.value.proxied != null ? each.value.proxied : var.default_proxied
}