locals {
  name_prefix = "${var.general.username}-${var.general.repo}-${var.general.environment}"

  alb_controller_role_name = "${local.name_prefix}-alb-controller-role"
}
