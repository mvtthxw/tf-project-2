resource "helm_release" "app_managed" {
  name             = "app-managed"
  namespace        = local.managed_app_namespace
  create_namespace = true
  chart            = local.managed_app_chart_path

  set = [
    {
      name  = "image.repository"
      value = data.aws_ecr_repository.app_managed.repository_url
    },
    {
      name  = "image.tag"
      value = var.app.managed_app_image_tag
    },
    {
      name  = "replicaCount"
      value = local.managed_app_replica_count
    },
    {
      name  = "namespace.create"
      value = false
    },
    {
      name  = "namespace.name"
      value = local.managed_app_namespace
    },
    {
      name  = "nodeSelector.eks\\.amazonaws\\.com/nodegroup"
      value = local.managed_app_node_group
    }
  ]
}
