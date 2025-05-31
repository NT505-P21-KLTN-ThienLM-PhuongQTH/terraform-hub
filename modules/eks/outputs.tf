output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster's name"
}

output "cluster_security_group_id" {
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description = "EKS cluster's security group ID"
}