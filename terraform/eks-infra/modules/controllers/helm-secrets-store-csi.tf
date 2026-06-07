resource "kubernetes_service_account_v1" "secrets_store_csi_provider_aws" {
  metadata {
    name      = "secrets-store-csi-driver-provider-aws"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.secrets_store_csi_provider_role.arn
    }
  }
}

resource "kubernetes_cluster_role_v1" "secrets_store_csi_provider_aws" {
  metadata {
    name = "secrets-store-csi-driver-provider-aws-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["get"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "secrets_store_csi_provider_aws" {
  metadata {
    name = "secrets-store-csi-driver-provider-aws-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.secrets_store_csi_provider_aws.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.secrets_store_csi_provider_aws.metadata[0].name
    namespace = kubernetes_service_account_v1.secrets_store_csi_provider_aws.metadata[0].namespace
  }
}

resource "helm_release" "secrets_store_csi_driver" {
  name       = "secrets-store-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  version    = "1.6.0"

  set = [
    {
      name  = "syncSecret.enabled"
      value = "true"
    },
  ]
}

resource "helm_release" "secrets_store_csi_driver_provider_aws" {
  name       = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  version    = "3.1.0"

  set = [
    {
      name  = "awsRegion"
      value = var.general.region
    },
    {
      name  = "rbac.install"
      value = "false"
    },
    {
      name  = "rbac.serviceAccountName"
      value = "secrets-store-csi-driver-provider-aws"
    },
    {
      name  = "secrets-store-csi-driver.install"
      value = "false"
    },
  ]

  depends_on = [
    module.secrets_store_csi_provider_role,
    kubernetes_service_account_v1.secrets_store_csi_provider_aws,
    kubernetes_cluster_role_binding_v1.secrets_store_csi_provider_aws,
    helm_release.secrets_store_csi_driver,
  ]
}
