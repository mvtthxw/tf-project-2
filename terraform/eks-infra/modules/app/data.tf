data "aws_ecr_repository" "app_managed" {
  name = var.app.managed_app_ecr_repo_name
}
