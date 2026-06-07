locals {
  name_prefix = "${var.general.username}-${var.general.repo}-${var.general.environment}"

  alb_controller_role_name             = "${local.name_prefix}-alb-controller-role"
  secrets_store_csi_provider_role_name = "${local.name_prefix}-secrets-store-role"
  cluster_autoscaler_role_name         = "${local.name_prefix}-ca-role"
}
