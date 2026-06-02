variable "general" {
  type = object({
    username    = string
    repo        = string
    environment = string
  })
}

variable "vpc" {
  type = object({
    cidr     = string
    az_count = number
  })
}
