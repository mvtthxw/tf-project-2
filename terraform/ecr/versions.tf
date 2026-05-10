terraform {
  required_version = ">= 1.15.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
  }
  backend "s3" {
    bucket  = "mvtthxw-tf-state"
    key     = "state/k8s-php-ecr.tfstate"
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
