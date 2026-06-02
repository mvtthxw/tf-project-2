module "vpc_cni_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.6.0"

  use_name_prefix = false
  name            = "${var.username}-${var.repo}-${var.environment}-vpc-cni-role"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  # VPC CNI >= 1.22 enables subnet discovery by default and requires DescribeSecurityGroups.
  # The module's IPv4 policy includes DescribeSubnets but not DescribeSecurityGroups yet.
  permissions = {
    vpc_cni_subnet_discovery = {
      sid       = "SubnetDiscovery"
      actions   = ["ec2:DescribeSecurityGroups"]
      resources = ["*"]
    }
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}
