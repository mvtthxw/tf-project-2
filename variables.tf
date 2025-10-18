# General
variable "username" {
  type        = string
  description = "The username of the person deploying the infrastructure"
}
variable "repo" {
  type        = string
  description = "The repository name where the Terraform code is stored"
}
variable "region" {
  type        = string
  description = "The AWS region to deploy resources in"
}

variable "environment" {
  type        = string
  description = "The environment for the deployment (e.g., dev, prod)"
}

# VPC
variable "cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}
variable "az_count" {
  type        = number
  description = "The number of Availability Zones to use"
}

# EKS Cluster
variable "cluster_version" {
  type        = string
  description = "The Kubernetes version for the EKS cluster"
}
