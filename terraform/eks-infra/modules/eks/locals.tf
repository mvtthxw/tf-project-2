locals {
  private_subnet_ids = var.private_subnets
  vpc_id             = var.vpc_id

  name_prefix                 = "${var.general.username}-${var.general.repo}-${var.general.environment}"
  cluster_name                = "${local.name_prefix}-eks"
  cluster_version             = var.eks.cluster_version
  eks_managed_node_group_name = "${var.general.username}-node-group"

  vpc_cni_role_name = "${local.name_prefix}-vpc-cni-role"
}
