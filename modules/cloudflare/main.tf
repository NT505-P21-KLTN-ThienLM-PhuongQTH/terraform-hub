# cloudflare/main.tf
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

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

# Create DNS records for each subdomain mapping
resource "cloudflare_record" "subdomains" {
  for_each = var.subdomain_mappings

  zone_id = var.cloudflare_zone_id
  name    = each.key
  value   = each.value.target_ip
  type    = "A"
  ttl     = each.value.ttl != null ? each.value.ttl : var.default_ttl
  proxied = each.value.proxied != null ? each.value.proxied : var.default_proxied
}
