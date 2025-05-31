# cloudflare/outputs.tf
output "dns_records" {
  description = "Created DNS records"
  value = {
    for k, v in cloudflare_record.subdomains : k => {
      name     = v.name
      value    = v.value
      hostname = v.hostname
      proxied  = v.proxied
      ttl      = v.ttl
    }
  }
}

output "zone_name" {
  description = "Zone name"
  value       = data.cloudflare_zone.domain.name
}