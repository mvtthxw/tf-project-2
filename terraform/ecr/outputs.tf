output "repository_urls" {
  description = "Map of short repository name -> ECR repository URL"
  value       = { for k, r in aws_ecr_repository.ecr : k => r.repository_url }
}

output "repository_arns" {
  description = "Map of short repository name -> ECR repository ARN"
  value       = { for k, r in aws_ecr_repository.ecr : k => r.arn }
}

output "registry_id" {
  description = "AWS account ID hosting the ECR registry"
  value       = values(aws_ecr_repository.ecr)[0].registry_id
}
