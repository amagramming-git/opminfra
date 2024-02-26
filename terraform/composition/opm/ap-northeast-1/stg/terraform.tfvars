########################################
# Environment setting
########################################
region           = "ap-northeast-1"
app_name         = "opm"
env              = "stg"
domain           = "stg.open-memo.com"

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
route53_domain_name = "open-memo.com"

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

repository_names = ["opmfront","opmback","opmdb"]

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

########################################
# ACM
########################################
securet_names = ["jwt_key","mysql_root_password","mysql_password"]

########################################
# Application Load Balancer
########################################
enable_deletion_protection_alb = "false"
ssl_policy                     = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"

fowerd_target_group_key = "opmfront"
target_groups = {
    opmfront = {
      backend_protocol                  = "HTTP"
      backend_port                      = "3000" # TODO
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
    opmback = {
      backend_protocol                  = "HTTP"
      backend_port                      = "8080"
      target_type                       = "ip"
      deregistration_delay              = 5
      load_balancing_cross_zone_enabled = true

      health_check = {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/api/actuator/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
      }

      # Theres nothing to attach here in this definition. Instead,
      # ECS will attach the IPs of the tasks to this target group
      create_attachment = false
    }
  }


########################################
# ECS
########################################
