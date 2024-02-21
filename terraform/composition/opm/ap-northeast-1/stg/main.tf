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
module "ecr_repository" {
  source = "../../../../infrastructure_modules/ecr_repository"

  for_each = toset(var.repository_names)
  repository_name = each.value

  create_lifecycle_policy           = var.create_lifecycle_policy
  repository_lifecycle_policy = jsonencode(var.repository_lifecycle_policy)

  repository_force_delete = var.repository_force_delete

  tags = local.ecr_tags
}

########################################
# Securet Manager
########################################
module "securet" {
  source = "../../../../infrastructure_modules/securet"

  for_each = toset(var.securet_names)
  name = each.value
}

########################################
# Application Load Balancer
########################################
module "alb" {
  source = "../../../../infrastructure_modules/alb"

  alb_name = local.alb_name

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  vpc_cidr_block  = module.vpc.vpc_cidr_block

  enable_deletion_protection   = var.enable_deletion_protection_alb
  certificate_arn = module.acm.acm_certificate_arn
  ssl_policy      = var.ssl_policy

  domain_name         = var.domain
  route53_domain_name = var.route53_domain_name
  tags = local.alb_tags

  target_groups = var.target_groups
  listener_rules = {
    opmback = {
      priority = 1
      actions = [{
        type             = "forward"
        target_group_arn = module.alb.target_groups["opmback"].arn
      }]
      conditions = [{
        path_pattern = {
          values = ["/api/*"]
        }
      }]
    }
    ex-fixed-response = {
      priority = 3
      actions = [{
        type         = "fixed-response"
        content_type = "text/plain"
        status_code  = 200
        message_body = "This is a fixed response"
      }]
      conditions = [{
        path_pattern = {
          values = ["/fixed"]
        }
      }]
    }
  }
  fowerd_target_group_key = var.fowerd_target_group_key
}

########################################
# ECS
########################################
module "ecs" {
  source = "../../../../infrastructure_modules/ecs"

  cluster_name = local.cluster_name

  containerPort_back             = var.containerPort_back
  image_back                     = "${module.ecr_repository[1].repository_url}:latest" # latest運用はやめたい
  containerPort_db               = var.containerPort_db
  image_db                       = "${module.ecr_repository[2].repository_url}:latest" # latest運用はやめたい
  target_group_arn_back          = module.alb.target_groups["opmback"].arn
  subnet_ids_back                = module.vpc.public_subnets
  source_security_group_id_back  = module.alb.security_group_id
  image_front                    = "${module.ecr_repository[0].repository_url}:latest" # latest運用はやめたい
  containerPort_front            = var.containerPort_front
  target_group_arn_front         = module.alb.target_groups["opmfront"].arn
  subnet_ids_front               = module.vpc.public_subnets
  source_security_group_id_front = module.alb.security_group_id

  tags = local.ecs_tags
}