output "gateway_ip" {
  value = module.instances.instances["${var.aws_project}-gateway"].public_ip
}

output "load_balancer" {
  value = module.load_balancer.load_balancer_dns_name
}

output "eks_cluster_name" {
  value = module.EKS.cluster_name
}