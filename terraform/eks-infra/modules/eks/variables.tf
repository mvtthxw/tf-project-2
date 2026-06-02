variable "general" {
  type = object({
    username    = string
    repo        = string
    environment = string
  })
}

variable "eks" {
  type = object({
    cluster_version           = string
    node_group_disk_size      = number
    node_group_instance_types = list(string)
    node_group_min_size       = number
    node_group_max_size       = number
    node_group_desired_size   = number
  })
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}
