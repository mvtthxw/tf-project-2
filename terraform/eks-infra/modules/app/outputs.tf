output "app_managed_helm_release_name" {
  description = "Helm release name of app-managed"
  value       = helm_release.app_managed.name
}

output "app_managed_helm_release_namespace" {
  description = "Helm release namespace of app-managed"
  value       = helm_release.app_managed.namespace
}

output "app_managed_helm_status" {
  description = "Helm release status of app-managed"
  value       = helm_release.app_managed.status
}

output "app_managed_image" {
  description = "Deployed container image (repository:tag)"
  value       = "${data.aws_ecr_repository.app_managed.repository_url}:${var.app.managed_app_image_tag}"
}
