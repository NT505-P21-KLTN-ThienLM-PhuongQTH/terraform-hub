resource "aws_eks_cluster" "main" {
  name     = "${var.name}-EKSCluster"
  role_arn = var.role_arn
  version  = var.k8s_version

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    endpoint_public_access  = false
    endpoint_private_access = true
    subnet_ids              = var.cluster_subnet_ids
  }

  kubernetes_network_config {
    service_ipv4_cidr = var.service_ipv4_cidr
  }
}

resource "aws_eks_addon" "main" {
  count        = length(var.eks_addons)
  cluster_name = aws_eks_cluster.main.name
  addon_name   = var.eks_addons[count.index]

  depends_on = [aws_eks_node_group.main]
}

// EKS NODE GROUP
resource "aws_eks_node_group" "main" {
  node_group_name = "${var.name}-EKSNodegroup"
  cluster_name    = aws_eks_cluster.main.name
  node_role_arn   = var.role_arn
  subnet_ids      = var.node_group_subnet_ids

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }

  update_config {
    max_unavailable = 1
  }

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size] // Ignore desired size 
  }
}

resource "aws_vpc_security_group_ingress_rule" "main" {
  security_group_id            = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description                  = "Allow all traffic from vpc to EKS cluster"
  from_port                    = -1
  to_port                      = -1
  ip_protocol                  = "-1"
  cidr_ipv4         = var.cluster_vpc_cidr
}