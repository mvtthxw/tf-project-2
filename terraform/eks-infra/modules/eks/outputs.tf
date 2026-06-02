output "cluster_id" {
  value = module.eks.cluster_id
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_iam_role_name" {
  value = module.eks.cluster_iam_role_name
}

output "eks_managed_node_groups" {
  value = module.eks.eks_managed_node_groups
}

output "fargate_profiles" {
  value = module.eks.fargate_profiles
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
