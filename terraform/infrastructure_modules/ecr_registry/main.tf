################################################################################
# ECR Registry
################################################################################

module "ecr_registry" {
  source = "../../resource_modules/container/ecr"

  create_repository = false

  # Registry Policy
  create_registry_policy = var.create_registry_policy
  registry_policy        = var.registry_policy

  # Registry Pull Through Cache Rules
  # registry_pull_through_cache_rules = {
  #   pub = {
  #     ecr_repository_prefix = "ecr-public"
  #     upstream_registry_url = "public.ecr.aws"
  #   }
  # }

  # Registry Scanning Configuration
  manage_registry_scanning_configuration = var.manage_registry_scanning_configuration
  registry_scan_type                     = var.registry_scan_type
  registry_scan_rules                    = var.registry_scan_rules

  # Registry Replication Configuration
  create_registry_replication_configuration = var.create_registry_replication_configuration
  registry_replication_rules                = var.registry_replication_rules
}