
################################################################################
# Cluster
################################################################################

module "ecs" {
  source = "../../resource_modules/container/ecs"

  cluster_name = var.cluster_name

  # Capacity provider
  # Allocate 100% capacity to FARGATE and then split
  # the remaining 0% capacity 50/50 between FARGATE
  # and FARGATE_SPOT.
  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        base   = 100
        weight = 50
      }
    }
  }

  services = var.services
  tags = var.tags
}
