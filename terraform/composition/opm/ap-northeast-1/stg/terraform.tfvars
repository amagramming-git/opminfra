########################################
# Environment setting
########################################
region           = "ap-northeast-1"
app_name         = "opm"
env              = "stg"

########################################
# VPC
########################################
vpc_cidr             = "10.1.0.0/16"
azs                  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
enable_nat_gateway   = "false"
# single_nat_gateway   = "true"


########################################
# ACM
########################################
domain = "open-memo.com"

########################################
# ECR Registry
########################################
manage_registry_scanning_configuration = "true"
registry_scan_type                     = "BASIC"
registry_scan_rules                    = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      filter         = "*"
      filter_type    = "WILDCARD"
    }
  ]
########################################
# ECR Repository
########################################

repository_name_opmfront = "opmfront"
repository_name_opmback  = "opmback"

create_lifecycle_policy           = "true"
repository_lifecycle_policy = {
  rules = [
    {
      rulePriority = 1,
      description  = "Keep last 30 images",
      selection = {
        tagStatus     = "tagged",
        tagPrefixList = ["v"],
        countType     = "imageCountMoreThan",
        countNumber   = 30
      },
      action = {
        type = "expire"
      }
    }
  ]
}
repository_force_delete = "true"
