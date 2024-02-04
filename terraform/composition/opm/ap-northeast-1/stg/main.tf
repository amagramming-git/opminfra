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
  # domeinは同一のAWSアカウントにて購入済みとする。
  domain = var.domain
}

########################################
# ECR Registry
########################################
module "ecr_registry" {
  source = "../../../../infrastructure_modules/ecr_registry"

  # Registry Policy
  create_registry_policy = var.create_registry_policy
  registry_policy        = var.registry_policy

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = var.manage_registry_scanning_configuration
  registry_scan_type                     = var.registry_scan_type
  registry_scan_rules                    = var.registry_scan_rules

  # Registry Replication Configuration
  create_registry_replication_configuration = var.create_registry_replication_configuration
  registry_replication_rules                = var.registry_replication_rules
}

########################################
# ECR Registry
########################################
module "ecr_repository_opmfront" {
  source = "../../../../infrastructure_modules/ecr_repository"

  repository_name = var.repository_name_opmfront

  create_lifecycle_policy           = var.create_lifecycle_policy
  repository_lifecycle_policy = jsonencode(var.repository_lifecycle_policy)

  repository_force_delete = var.repository_force_delete

  tags = local.ecr_tags
}
module "ecr_repository_opmback" {
  source = "../../../../infrastructure_modules/ecr_repository"

  repository_name = var.repository_name_opmback

  create_lifecycle_policy           = var.create_lifecycle_policy
  repository_lifecycle_policy = jsonencode(var.repository_lifecycle_policy)

  repository_force_delete = var.repository_force_delete

  tags = local.ecr_tags
}