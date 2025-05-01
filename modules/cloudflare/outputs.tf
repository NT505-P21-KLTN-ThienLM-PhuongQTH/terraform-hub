# cloudflare/outputs.tf
output "subdomain_name" {
  description = "Tên subdomain đã tạo"
  value       = "${var.subdomain}.${data.cloudflare_zone.domain.name}"
}

output "target_ip" {
  description = "IP address mà subdomain trỏ đến"
  value       = var.use_elastic_ip ? var.elastic_ip : data.aws_instance.target_instance.public_ip
}

output "record_id" {
  description = "ID của DNS record"
  value       = cloudflare_record.subdomain.id
}