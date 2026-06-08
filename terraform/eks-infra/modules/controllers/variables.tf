variable "general" {
  type = object({
    username    = string
    repo        = string
    environment = string
    region      = string
  })
}

variable "vpc_id" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "eks_oidc_provider_arn" {
  type = string
}
