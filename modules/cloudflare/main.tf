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

data "aws_instance" "target_instance" {
  instance_id = var.ec2_instance_id
}

resource "cloudflare_record" "subdomain" {
  zone_id = var.cloudflare_zone_id
  name    = var.subdomain
  value   = var.use_elastic_ip ? var.elastic_ip : data.aws_instance.target_instance.public_ip
  type    = "A"
  ttl     = var.ttl
  proxied = var.enable_proxy
}

data "cloudflare_zone" "domain" {
  zone_id = var.cloudflare_zone_id
}