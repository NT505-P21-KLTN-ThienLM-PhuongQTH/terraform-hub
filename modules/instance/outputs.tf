output "instances" {
  value = {
    for instance in aws_instance.main : instance.tags_all["Name"] => {
      id = instance.id
      public_ip = instance.public_ip
      private_ip = instance.private_ip
    }
  }
}

output "network_interfaces" {
  value = {
    for network_interface in aws_network_interface.main : network_interface.tags_all["Name"] => network_interface.id
  }
}