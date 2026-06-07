resource "kubernetes_service_account_v1" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.cluster_autoscaler_role.arn
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  namespace  = "kube-system"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.57.0"

  set = [
    {
      name  = "autoDiscovery.clusterName"
      value = var.eks.cluster_name
    },
    {
      name  = "awsRegion"
      value = var.general.region
    },
    {
      name  = "cloudProvider"
      value = "aws"
    },
    {
      name  = "rbac.serviceAccount.create"
      value = "false"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    },
  ]

  depends_on = [
    module.cluster_autoscaler_role,
    kubernetes_service_account_v1.cluster_autoscaler,
  ]
}
