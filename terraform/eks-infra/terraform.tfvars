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
  cluster_version           = "1.35"
  node_group_disk_size      = 20
  node_group_min_size       = 1
  node_group_max_size       = 4
  node_group_desired_size   = 1
  node_group_instance_types = ["t3.medium"]
}
