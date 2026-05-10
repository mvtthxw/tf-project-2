terraform {
  required_version = ">= 1.15.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
    # helm = {
    #   source  = "hashicorp/helm"
    #   version = "3.1.1"
    # }
    # kubernetes = {
    #   source  = "hashicorp/kubernetes"
    #   version = "3.1.0"
    # }
  }
  backend "s3" {
    bucket  = "mvtthxw-tf-state"
    key     = "state/k8s-php-eks-infra.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Owner       = var.username
      Repo        = var.repo
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# data "aws_eks_cluster_auth" "auth" {
#   name = module.eks.cluster_name
# }

# provider "kubernetes" {
#   host                   = module.eks.cluster_endpoint
#   token                  = data.aws_eks_cluster_auth.auth.token
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
# }

# provider "helm" {}
