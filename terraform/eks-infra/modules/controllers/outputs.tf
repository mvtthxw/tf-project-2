# AWS Load Balancer Controller — IAM (IRSA)
output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller service account (IRSA)"
  value       = module.alb_controller_role.arn
}

output "aws_load_balancer_controller_role_name" {
  description = "IAM role name for the AWS Load Balancer Controller"
  value       = module.alb_controller_role.name
}

# AWS Load Balancer Controller — Kubernetes ServiceAccount
output "aws_load_balancer_controller_service_account_name" {
  description = "Kubernetes service account name used by the AWS Load Balancer Controller"
  value       = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].name
}

output "aws_load_balancer_controller_service_account_namespace" {
  description = "Kubernetes namespace of the AWS Load Balancer Controller service account"
  value       = kubernetes_service_account_v1.aws_load_balancer_controller.metadata[0].namespace
}

# AWS Load Balancer Controller — Helm release
output "aws_load_balancer_controller_helm_release_name" {
  description = "Helm release name of the AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.name
}

output "aws_load_balancer_controller_helm_release_namespace" {
  description = "Helm release namespace of the AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.namespace
}

output "aws_load_balancer_controller_helm_chart_version" {
  description = "Helm chart version of the AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.version
}

output "aws_load_balancer_controller_helm_chart" {
  description = "Helm chart name of the AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.chart
}

output "aws_load_balancer_controller_helm_status" {
  description = "Helm release status of the AWS Load Balancer Controller"
  value       = helm_release.aws_load_balancer_controller.status
}

# Cluster Autoscaler — IAM (IRSA)
output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for the Cluster Autoscaler service account (IRSA)"
  value       = module.cluster_autoscaler_role.arn
}

output "cluster_autoscaler_role_name" {
  description = "IAM role name for the Cluster Autoscaler"
  value       = module.cluster_autoscaler_role.name
}

# Cluster Autoscaler — Kubernetes ServiceAccount
output "cluster_autoscaler_service_account_name" {
  description = "Kubernetes service account name used by the Cluster Autoscaler"
  value       = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
}

output "cluster_autoscaler_service_account_namespace" {
  description = "Kubernetes namespace of the Cluster Autoscaler service account"
  value       = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].namespace
}

# Cluster Autoscaler — Helm release
output "cluster_autoscaler_helm_release_name" {
  description = "Helm release name of the Cluster Autoscaler"
  value       = helm_release.cluster_autoscaler.name
}

output "cluster_autoscaler_helm_release_namespace" {
  description = "Helm release namespace of the Cluster Autoscaler"
  value       = helm_release.cluster_autoscaler.namespace
}

output "cluster_autoscaler_helm_chart_version" {
  description = "Helm chart version of the Cluster Autoscaler"
  value       = helm_release.cluster_autoscaler.version
}

output "cluster_autoscaler_helm_chart" {
  description = "Helm chart name of the Cluster Autoscaler"
  value       = helm_release.cluster_autoscaler.chart
}

output "cluster_autoscaler_helm_status" {
  description = "Helm release status of the Cluster Autoscaler"
  value       = helm_release.cluster_autoscaler.status
}

# Secrets Store CSI — AWS provider IAM (IRSA)
output "secrets_store_csi_provider_role_arn" {
  description = "IAM role ARN for the Secrets Store CSI AWS provider service account (IRSA)"
  value       = module.secrets_store_csi_provider_role.arn
}

output "secrets_store_csi_provider_role_name" {
  description = "IAM role name for the Secrets Store CSI AWS provider"
  value       = module.secrets_store_csi_provider_role.name
}

# Secrets Store CSI — AWS provider Kubernetes resources
output "secrets_store_csi_provider_service_account_name" {
  description = "Kubernetes service account name used by the Secrets Store CSI AWS provider"
  value       = kubernetes_service_account_v1.secrets_store_csi_provider_aws.metadata[0].name
}

output "secrets_store_csi_provider_service_account_namespace" {
  description = "Kubernetes namespace of the Secrets Store CSI AWS provider service account"
  value       = kubernetes_service_account_v1.secrets_store_csi_provider_aws.metadata[0].namespace
}

output "secrets_store_csi_provider_cluster_role_name" {
  description = "ClusterRole name for the Secrets Store CSI AWS provider"
  value       = kubernetes_cluster_role_v1.secrets_store_csi_provider_aws.metadata[0].name
}

output "secrets_store_csi_provider_cluster_role_binding_name" {
  description = "ClusterRoleBinding name for the Secrets Store CSI AWS provider"
  value       = kubernetes_cluster_role_binding_v1.secrets_store_csi_provider_aws.metadata[0].name
}

# Secrets Store CSI Driver — Helm release
output "secrets_store_csi_driver_helm_release_name" {
  description = "Helm release name of the Secrets Store CSI driver"
  value       = helm_release.secrets_store_csi_driver.name
}

output "secrets_store_csi_driver_helm_release_namespace" {
  description = "Helm release namespace of the Secrets Store CSI driver"
  value       = helm_release.secrets_store_csi_driver.namespace
}

output "secrets_store_csi_driver_helm_chart_version" {
  description = "Helm chart version of the Secrets Store CSI driver"
  value       = helm_release.secrets_store_csi_driver.version
}

output "secrets_store_csi_driver_helm_chart" {
  description = "Helm chart name of the Secrets Store CSI driver"
  value       = helm_release.secrets_store_csi_driver.chart
}

output "secrets_store_csi_driver_helm_status" {
  description = "Helm release status of the Secrets Store CSI driver"
  value       = helm_release.secrets_store_csi_driver.status
}

# Secrets Store CSI AWS Provider — Helm release
output "secrets_store_csi_provider_aws_helm_release_name" {
  description = "Helm release name of the Secrets Store CSI AWS provider"
  value       = helm_release.secrets_store_csi_driver_provider_aws.name
}

output "secrets_store_csi_provider_aws_helm_release_namespace" {
  description = "Helm release namespace of the Secrets Store CSI AWS provider"
  value       = helm_release.secrets_store_csi_driver_provider_aws.namespace
}

output "secrets_store_csi_provider_aws_helm_chart_version" {
  description = "Helm chart version of the Secrets Store CSI AWS provider"
  value       = helm_release.secrets_store_csi_driver_provider_aws.version
}

output "secrets_store_csi_provider_aws_helm_chart" {
  description = "Helm chart name of the Secrets Store CSI AWS provider"
  value       = helm_release.secrets_store_csi_driver_provider_aws.chart
}

output "secrets_store_csi_provider_aws_helm_status" {
  description = "Helm release status of the Secrets Store CSI AWS provider"
  value       = helm_release.secrets_store_csi_driver_provider_aws.status
}
