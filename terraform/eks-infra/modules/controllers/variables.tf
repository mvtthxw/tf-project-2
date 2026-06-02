variable "general" {
  type = object({
    username    = string
    repo        = string
    environment = string
    region      = string
  })
}

variable "vpc" {
  type = object({
    vpc_id = string
  })
}



variable "eks" {
  type = object({
    cluster_name      = string
    oidc_provider_arn = string
  })
}
