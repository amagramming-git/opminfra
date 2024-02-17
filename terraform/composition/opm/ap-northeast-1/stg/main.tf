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
  route53_domain_name = var.route53_domain_name
  domain_name         = var.domain
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
module "ecr_repository_opmdb" {
  source = "../../../../infrastructure_modules/ecr_repository"

  repository_name = var.repository_name_opmdb

  create_lifecycle_policy           = var.create_lifecycle_policy
  repository_lifecycle_policy = jsonencode(var.repository_lifecycle_policy)

  repository_force_delete = var.repository_force_delete

  tags = local.ecr_tags
}

########################################
# Application Load Balancer
########################################
module "alb" {
  source = "../../../../infrastructure_modules/alb"

  alb_name = local.alb_name

  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets

  enable_deletion_protection   = var.enable_deletion_protection_alb
  security_group_ingress_rules = var.security_group_ingress_rules_alb
  security_group_egress_rules  = {
      all = {
        ip_protocol = "-1"
        cidr_ipv4   = module.vpc.vpc_cidr_block
      }
    }
  certificate_arn = module.acm.acm_certificate_arn
  ssl_policy      = var.ssl_policy

  domain_name         = var.domain
  route53_domain_name = var.route53_domain_name
  tags = local.alb_tags
}
########################################
# ECS
########################################
module "ecs" {
  source = "../../../../infrastructure_modules/ecs"

  cluster_name = local.cluster_name

  containerPort_back             = var.containerPort_back
  image_back                     = "${module.ecr_repository_opmback.repository_url}:latest" # latest運用はやめたい
  containerPort_db               = var.containerPort_db
  image_db                       = "${module.ecr_repository_opmdb.repository_url}:latest" # これはstg環境のみ
  target_group_arn_back          = module.alb.target_groups["opmback"].arn
  subnet_ids_back                = module.vpc.public_subnets
  source_security_group_id_back  = module.alb.security_group_id
  image_front                    = "${module.ecr_repository_opmfront.repository_url}:latest" # latest運用はやめたい
  containerPort_front            = var.containerPort_front
  target_group_arn_front         = module.alb.target_groups["opmfront"].arn
  subnet_ids_front               = module.vpc.public_subnets
  source_security_group_id_front = module.alb.security_group_id

  tags = local.ecs_tags
}