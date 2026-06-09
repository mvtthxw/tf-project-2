variable "general" {
  type = object({
    username    = string
    repo        = string
    environment = string
    region      = string
  })
}

variable "app" {
  description = "Application workload settings"
  type = object({
    managed_app_ecr_repo_name = string
    managed_app_image_tag     = string
    managed_app_replica_count = optional(number)
    managed_app_namespace     = optional(string)
  })
}
