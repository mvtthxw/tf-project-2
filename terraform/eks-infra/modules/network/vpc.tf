module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = local.vpc_name
  cidr = var.vpc.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.vpc.az_count)
  public_subnets  = [for i in range(var.vpc.az_count) : cidrsubnet(var.vpc.cidr, 4, i)]
  private_subnets = [for i in range(var.vpc.az_count) : cidrsubnet(var.vpc.cidr, 4, i + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  map_public_ip_on_launch = true

  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }
}
