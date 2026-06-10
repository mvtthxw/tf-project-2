# General
variable "general" {
  description = "General variables"
  type = object({
    username    = string
    repo        = string
    region      = string
    environment = string
  })
}

# VPC
variable "vpc" {
  description = "VPC variables"
  type = object({
    cidr     = string
    az_count = number
  })
}

# EKS Cluster
variable "eks" {
  description = "EKS cluster variables"
  type = object({
    cluster_version           = string
    node_group_disk_size      = number
    node_group_instance_types = list(string)
    node_group_min_size       = number
    node_group_max_size       = number
    node_group_desired_size   = number
  })
}

# Application workloads
variable "app" {
  description = "Application workload settings"
  type = object({
    managed_app_ecr_repo_name = string
    managed_app_image_tag     = string
    managed_app_replica_count = optional(number)
    managed_app_namespace     = optional(string)
    managed_app_ssm_value     = optional(string, "managed-node-ssm-value")

    fargate_app_ecr_repo_name = string
    fargate_app_image_tag     = string
    fargate_app_replica_count = optional(number)
    fargate_app_namespace     = optional(string)
  })
}
