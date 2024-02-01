########################################
# VPC
########################################
module "vpc" {
  source = "../../../../infrastructure_modules/vpc" # using infra module VPC which acts like a facade to many sub-resources

  name                 = local.vpc_name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  ## Common tag metadata ##
  tags     = local.vpc_tags
  env      = var.env
  app_name = var.app_name
  region   = var.region
}

########################################
# ACM
########################################
module "acm" {
  source = "../../../../infrastructure_modules/acm"
  domain = var.domain
}