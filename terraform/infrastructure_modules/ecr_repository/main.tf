# data "aws_caller_identity" "current" {}

################################################################################
# ECR Repository
################################################################################

module "ecr" {
  source = "../../resource_modules/container/ecr"

  repository_name = var.repository_name

  # repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  create_lifecycle_policy           = var.create_lifecycle_policy
  repository_lifecycle_policy = var.repository_lifecycle_policy

  repository_force_delete = var.repository_force_delete

  tags = var.tags
}
