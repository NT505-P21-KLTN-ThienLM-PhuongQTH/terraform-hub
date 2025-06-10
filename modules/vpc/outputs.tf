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

output "public_route_table_id" {
  description = "ID of the public Route Table"
  value       = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "IDs of the private Route Tables"
  value       = length(aws_route_table.private) > 0 ? aws_route_table.private[0].id : null
}