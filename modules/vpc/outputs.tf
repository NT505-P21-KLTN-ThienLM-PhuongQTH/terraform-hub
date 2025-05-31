output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets_id" {
  value = aws_subnet.public[*].id
}

output "private_subnets_id" {
  value = aws_subnet.private[*].id
}

output "public_subnets_cidr" {
  value = aws_subnet.public[*].cidr_block
}

output "private_subnets_cidr" {
  value = aws_subnet.private[*].cidr_block
}
