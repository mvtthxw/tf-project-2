data "aws_ecr_repository" "app_managed" {
  name = var.app.managed_app_ecr_repo_name
}

data "aws_ecr_repository" "app_fargate" {
  name = var.app.fargate_app_ecr_repo_name
}
