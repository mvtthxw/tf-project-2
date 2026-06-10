# General
general = {
  username    = "mvtthxw"
  repo        = "k8s-php-infra"
  region      = "us-east-1"
  environment = "dev"
}

# VPC
vpc = {
  cidr     = "10.100.0.0/20"
  az_count = 2
}

# EKS Cluster
eks = {
  cluster_version           = "1.36"
  node_group_disk_size      = 20
  node_group_min_size       = 1
  node_group_max_size       = 3
  node_group_desired_size   = 1
  node_group_instance_types = ["t4g.medium"]
}

# Application workloads
app = {
  managed_app_ecr_repo_name = "mvtthxw-k8s-php-dev-app-managed"
  managed_app_image_tag     = "v1.0.0"
  managed_app_namespace     = "managed-apps"
  managed_app_replica_count = 1
  managed_app_ssm_value     = "Example value"

  fargate_app_ecr_repo_name = "mvtthxw-k8s-php-dev-app-fargate"
  fargate_app_image_tag     = "v1.0.0"
  fargate_app_namespace     = "fargate-apps"
  fargate_app_replica_count = 1
}
