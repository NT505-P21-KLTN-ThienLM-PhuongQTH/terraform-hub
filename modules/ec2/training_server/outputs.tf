output "ip" {
  value = module.training_server.public_ip
}

output "instance_id" {
    description = "ID của EC2 instance"
    value       = module.training_server.instance_id
}