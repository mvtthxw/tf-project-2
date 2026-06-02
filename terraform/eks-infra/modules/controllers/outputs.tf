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
