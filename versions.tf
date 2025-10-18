terraform {
  required_version = "1.13.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.16.0"
    }
  }
  backend "s3" {
    bucket         = "medyk-tf-state"
    key            = "state/project-2-eks-cluster.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "medyk-tf-lock"
    encrypt        = true
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