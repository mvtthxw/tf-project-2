resource "helm_release" "app_fargate" {
  name             = "app-fargate"
  namespace        = local.fargate_app_namespace
  create_namespace = true
  chart            = local.fargate_app_chart_path

  set = [
    {
      name  = "image.repository"
      value = data.aws_ecr_repository.app_fargate.repository_url
    },
    {
      name  = "image.tag"
      value = var.app.fargate_app_image_tag
    },
    {
      name  = "replicaCount"
      value = local.fargate_app_replica_count
    },
    {
      name  = "namespace.create"
      value = false
    },
    {
      name  = "namespace.name"
      value = local.fargate_app_namespace
    }
  ]
}
