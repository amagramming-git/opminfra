# https://github.com/terraform-aws-modules/terraform-aws-vpc/blob/master/examples/simple/main.tf
# 20240128
################################################################################
# VPC Module
################################################################################
module "vpc" {
  source = "../../resource_modules/network/vpc"

  name = var.name
  cidr = var.vpc_cidr

  azs              = var.azs
  public_subnets   = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k)] # add
  private_subnets  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 4)] # change
  database_subnets = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 8, k + 8)] # add

  enable_nat_gateway = var.enable_nat_gateway # add
  single_nat_gateway = var.single_nat_gateway # add

  tags = var.tags
}