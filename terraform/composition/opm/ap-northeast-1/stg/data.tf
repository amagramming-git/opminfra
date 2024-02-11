locals {
  tags = {
    Environment = var.env
    Application = var.app_name
    Terraform   = true
  }

  ## VPC ##
  vpc_name = "vpc-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  vpc_tags = merge(
    local.tags,
    tomap({
      "VPC-Name" = local.vpc_name
    })
  )
  ## ECR ##
  ecr_tags = local.tags

  ## ALB ##
  alb_name = "alb-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  alb_tags = local.tags

  ## ECS ##
  cluster_name = "cluster-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  ecs_tags = local.tags
}