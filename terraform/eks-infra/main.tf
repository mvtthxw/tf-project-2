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
