module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = "${var.username}-${var.repo}-${var.environment}-vpc"
  cidr = var.cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, var.az_count)
  public_subnets  = [for i in range(var.az_count) : cidrsubnet(var.cidr, 4, i)]
  private_subnets = [for i in range(var.az_count) : cidrsubnet(var.cidr, 4, i + 10)]

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  map_public_ip_on_launch = true
}
