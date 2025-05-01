output "instance_id" {
  value = aws_instance.ec2_instance[0].id
}

output "public_ip" {
  value = aws_instance.ec2_instance[0].public_ip
}
