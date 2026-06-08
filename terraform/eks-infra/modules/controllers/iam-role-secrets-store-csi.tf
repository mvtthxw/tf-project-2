module "secrets_store_csi_provider_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.6.0"

  use_name_prefix = false
  name            = local.secrets_store_csi_provider_role_name

  attach_external_secrets_policy = true
  external_secrets_ssm_parameter_arns = [
    "arn:aws:ssm:${var.general.region}:${data.aws_caller_identity.current.account_id}:parameter/*",
  ]

  oidc_providers = {
    main = {
      provider_arn               = var.eks_oidc_provider_arn
      namespace_service_accounts = ["kube-system:secrets-store-csi-driver-provider-aws"]
    }
  }
}
