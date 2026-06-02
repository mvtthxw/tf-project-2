# VPC
output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR VPC"
  value       = module.network.vpc_cidr_block
}

output "public_subnets" {
  description = "List of public subnets"
  value       = module.network.public_subnets
}

output "private_subnets" {
  description = "List of private subnets"
  value       = module.network.private_subnets
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.network.nat_gateway_ids
}

output "internet_gateway_id" {
  description = "ID Internet Gateway"
  value       = module.network.internet_gateway_id
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = module.network.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.network.private_route_table_ids
}

output "availability_zones" {
  description = "List of Availability Zones"
  value       = module.network.availability_zones
}

# EKS Cluster
output "cluster_id" {
  description = "Cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_endpoint" {
  description = "Endpoint API Kubernetes"
  value       = module.eks.cluster_endpoint
}

output "cluster_ca_certificate" {
  description = "Cluster Certificate Authority Data"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_iam_role_arn" {
  description = "Cluster IAM Role ARN"
  value       = module.eks.cluster_iam_role_name
}

output "node_groups" {
  description = "EKS Managed Node Groups"
  value       = module.eks.eks_managed_node_groups
}

output "fargate_profiles" {
  description = "EKS Fargate Profiles"
  value       = module.eks.fargate_profiles
}

output "node_security_group_id" {
  description = "EKS Node Security Group ID"
  value       = module.eks.node_security_group_id
}

output "oidc_issuer_url" {
  description = "EKS OIDC Issuer URL"
  value       = module.eks.cluster_oidc_issuer_url
}

# Controllers
output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller (IRSA)"
  value       = module.controllers.aws_load_balancer_controller_role_arn
}

output "aws_load_balancer_controller_role_name" {
  description = "IAM role name for the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_role_name
}

output "aws_load_balancer_controller_service_account_name" {
  description = "Kubernetes service account name for the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_service_account_name
}

output "aws_load_balancer_controller_service_account_namespace" {
  description = "Kubernetes namespace of the AWS Load Balancer Controller service account"
  value       = module.controllers.aws_load_balancer_controller_service_account_namespace
}

output "aws_load_balancer_controller_helm_release_name" {
  description = "Helm release name of the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_helm_release_name
}

output "aws_load_balancer_controller_helm_release_namespace" {
  description = "Helm release namespace of the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_helm_release_namespace
}

output "aws_load_balancer_controller_helm_chart_version" {
  description = "Helm chart version of the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_helm_chart_version
}

output "aws_load_balancer_controller_helm_chart" {
  description = "Helm chart name of the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_helm_chart
}

output "aws_load_balancer_controller_helm_status" {
  description = "Helm release status of the AWS Load Balancer Controller"
  value       = module.controllers.aws_load_balancer_controller_helm_status
}
