locals {
  name_prefix = "${var.general.username}-${var.general.repo}-${var.general.environment}"
  vpc_name    = "${local.name_prefix}-vpc"
}
