locals {
  managed_app_chart_path    = abspath("${path.module}/../../../../helm/app-managed")
  managed_app_namespace     = coalesce(var.app.managed_app_namespace, "managed-apps")
  managed_app_replica_count = coalesce(var.app.managed_app_replica_count, 1)
  managed_app_node_group    = "${var.general.username}-node-group"
}
