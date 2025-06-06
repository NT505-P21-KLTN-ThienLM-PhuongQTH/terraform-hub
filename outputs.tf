output "gateway_ip" {
  value = module.instances.instances["${var.aws_project}-gateway"].public_ip
}
#
# output "eks_cluster_name" {
#   value = module.EKS.cluster_name
# }