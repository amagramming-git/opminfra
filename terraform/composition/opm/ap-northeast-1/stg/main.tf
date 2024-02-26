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
  services     = {
    backend = {
      cpu    = 1024
      memory = 2048
      assign_public_ip = true

      # Container definition(s)
      container_definitions = {
        opmback = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${module.ecr_repository["opmback"].repository_url}:1.0"

          port_mappings = [
            {
              name          = "opmback"
              containerPort = 8080
              hostPort      = 8080
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          enable_cloudwatch_logging = true
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/backend/opmback"
              awslogs-region        = "ap-northeast-1"
              awslogs-stream-prefix = "opmback"
            }
          }
          dependencies = [{
            containerName = "opmdb"
            condition     = "START"
          }]
          environment = [
            { "name": "SPRING_DATASOURCE_URL", "value": "jdbc:mysql://localhost/openmemo" },
            { "name": "ALLOWED_ORIGIN_OPMFRONT", "value": "https://stg.open-memo.com" },
            { "name": "MYSQL_DATABASE", "value": "openmemo" },
            { "name": "MYSQL_USER", "value": "openmemouser" },
            { "name": "TZ", "value": "Asia/Tokyo" }
          ]
          secrets     = [
            { 
              "name": "JWT_KEY", 
              "valueFrom": "${module.securet["jwt_key"].arn}"
            },
            { 
              "name": "MYSQL_ROOT_PASSWORD", 
              "valueFrom": "${module.securet["mysql_root_password"].arn}"
            },
            { 
              "name": "MYSQL_PASSWORD", 
              "valueFrom": "${module.securet["mysql_password"].arn}"
            }
          ]
        }
        opmdb = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${module.ecr_repository["opmdb"].repository_url}:1.0"

          port_mappings = [
            {
              name          = "opmdb"
              containerPort = 3306
              hostPort      = 3306
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          enable_cloudwatch_logging = true
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/backend/opmdb"
              awslogs-region        = "ap-northeast-1"
              awslogs-stream-prefix = "opmdb"
            }
          }
          environment = [
            { "name": "MYSQL_DATABASE", "value": "openmemo" },
            { "name": "MYSQL_USER", "value": "openmemouser" },
            { "name": "TZ", "value": "Asia/Tokyo" },
          ]
          secrets     = [
            { 
              "name": "MYSQL_ROOT_PASSWORD", 
              "valueFrom": "${module.securet["mysql_root_password"].arn}"
            },
            { 
              "name": "MYSQL_PASSWORD", 
              "valueFrom": "${module.securet["mysql_password"].arn}"
            }
          ]
        }
      }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["opmback"].arn
          container_name   = "opmback"
          container_port   = 8080
        }
      }

      # tasks_iam_role_name        = "opmback-tasks"
      # tasks_iam_role_description = "Example tasks IAM role for opmback"
      # tasks_iam_role_policies = {
      #   ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      # }
      # tasks_iam_role_statements = [
      #   {
      #     actions   = ["s3:List*"]
      #     resources = ["arn:aws:s3:::*"]
      #   }
      # ]

      subnet_ids = module.vpc.public_subnets
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = 8080
          to_port                  = 8080
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    },
    frontend = {
        memory = 1024
      cpu    = 512
      assign_public_ip = true

      # Container definition(s)
      container_definitions = {
        opmfront = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = "${module.ecr_repository["opmfront"].repository_url}:1.0"

          port_mappings = [
            {
              name          = "opmfront"
              containerPort = 3000
              hostPort      = 3000
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          enable_cloudwatch_logging = true
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/frontend/opmfront"
              awslogs-region        = "ap-northeast-1"
              awslogs-stream-prefix = "opmfront"
            }
          }
          environment = [
            { "name": "NODE_ENV", "value": "production" }
          ]
        }
      }

      # service_connect_configuration = {
      #   namespace = aws_service_discovery_http_namespace.this.arn
      #   service = {
      #     client_alias = {
      #       port     = local.container_port
      #       dns_name = local.container_name
      #     }
      #     port_name      = local.container_name
      #     discovery_name = local.container_name
      #   }
      # }

      load_balancer = {
        service = {
          target_group_arn = module.alb.target_groups["opmfront"].arn
          container_name   = "opmfront"
          container_port   = 3000
        }
      }

      # tasks_iam_role_name        = "opmfront-tasks"
      # tasks_iam_role_description = "Example tasks IAM role for opmfront"
      # tasks_iam_role_policies = {
      #   ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      # }
      # tasks_iam_role_statements = [
      #   {
      #     actions   = ["s3:List*"]
      #     resources = ["arn:aws:s3:::*"]
      #   }
      # ]

      subnet_ids = module.vpc.public_subnets
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = 3000
          to_port                  = 3000
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }
  tags = local.ecs_tags
}