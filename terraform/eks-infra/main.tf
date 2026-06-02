module "network" {
  source = "./modules/network"

  general = var.general
  vpc     = var.vpc
}

module "eks" {
  source = "./modules/eks"

  general         = var.general
  eks             = var.eks
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
}

module "controllers" {
  source = "./modules/controllers"

  general = var.general
  vpc = {
    vpc_id = module.network.vpc_id
  }
  eks = {
    cluster_name      = module.eks.cluster_name
    oidc_provider_arn = module.eks.oidc_provider_arn
  }

  depends_on = [module.eks]
}
