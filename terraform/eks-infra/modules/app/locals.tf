locals {
  managed_app_chart_path         = abspath("${path.module}/../../../../helm/app-managed")
  managed_app_namespace          = coalesce(var.app.managed_app_namespace, "managed-apps")
  managed_app_replica_count      = coalesce(var.app.managed_app_replica_count, 1)
  managed_app_node_group         = "${var.general.username}-node-group"
  managed_app_ssm_parameter_name = "/${var.general.username}/${var.general.repo}/${var.general.environment}/app-managed/PARAMS_STORE"

  fargate_app_chart_path    = abspath("${path.module}/../../../../helm/app-fargate")
  fargate_app_namespace     = coalesce(var.app.fargate_app_namespace, "fargate-apps")
  fargate_app_replica_count = coalesce(var.app.fargate_app_replica_count, 1)
}
