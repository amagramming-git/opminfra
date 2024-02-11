
locals {
  container_name_back = "opmback"
  container_name_front = "opmfront"
  container_name_db = "db"
}
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

  services = {
    backend = {
      cpu    = 1024
      memory = 2048
      assign_public_ip = true

      # Container definition(s)
      container_definitions = {
        (local.container_name_back) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = var.image_back

          port_mappings = [
            {
              name          = local.container_name_back
              containerPort = var.containerPort_back
              hostPort      = var.containerPort_back
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
            containerName = local.container_name_db
            condition     = "START"
          }]
          environment = [
            { "name": "SPRING_DATASOURCE_URL", "value": "jdbc:mysql://localhost/openmemo" },
            { "name": "ALLOWED_ORIGIN_OPMFRONT", "value": "https://open-memo.com" },
            { "name": "JWT_KEY", "value": "jxgEQeXHuPq8VdbyYFNkANdudQ53YUn4" },
            { "name": "MYSQL_ROOT_PASSWORD", "value": "root" },
            { "name": "MYSQL_DATABASE", "value": "openmemo" },
            { "name": "MYSQL_USER", "value": "openmemouser" },
            { "name": "MYSQL_PASSWORD", "value": "0pen_memo_user" },
            { "name": "TZ", "value": "Asia/Tokyo" },
          ]
          # secrets     = [
          #   { 
          #     "name": "JWT_KEY", 
          #     "valueFrom": "arn:aws:secretsmanager:ap-northeast-1:123456789012:secret:token-json:json_key::" 
          #   },
          #   {
          #     "name": "TOKEN_FROM_PARAMERTER_STORE", 
          #     "valueFrom": 
          #       "arn:aws:ssm:ap-northeast-1:123456789012:parameter/foo_token" 
          #   }
          # ]
        }
        (local.container_name_db) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = var.image_db

          port_mappings = [
            {
              name          = local.container_name_db
              containerPort = var.containerPort_db
              hostPort      = var.containerPort_db
              protocol      = "tcp"
            }
          ]

          # Example image used requires access to write to root filesystem
          readonly_root_filesystem = false

          enable_cloudwatch_logging = true
          log_configuration = {
            log_driver = "awslogs"
            options = {
              awslogs-group         = "/aws/ecs/backend/db"
              awslogs-region        = "ap-northeast-1"
              awslogs-stream-prefix = "db"
            }
          }
          environment = [
            { "name": "MYSQL_ROOT_PASSWORD", "value": "root" },
            { "name": "MYSQL_DATABASE", "value": "openmemo" },
            { "name": "MYSQL_USER", "value": "openmemouser" },
            { "name": "MYSQL_PASSWORD", "value": "0pen_memo_user" },
            { "name": "TZ", "value": "Asia/Tokyo" },
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
          target_group_arn = var.target_group_arn_back
          container_name   = local.container_name_back
          container_port   = var.containerPort_back
        }
      }

      tasks_iam_role_name        = "opmback-tasks"
      tasks_iam_role_description = "Example tasks IAM role for opmback"
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      subnet_ids = var.subnet_ids_back
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = var.containerPort_back
          to_port                  = var.containerPort_back
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = var.source_security_group_id_back
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
        (local.container_name_front) = {
          cpu       = 512
          memory    = 1024
          essential = true
          image     = var.image_front

          port_mappings = [
            {
              name          = local.container_name_front
              containerPort = var.containerPort_front
              hostPort      = var.containerPort_front
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
          target_group_arn = var.target_group_arn_front
          container_name   = local.container_name_front
          container_port   = var.containerPort_front
        }
      }

      tasks_iam_role_name        = "opmfront-tasks"
      tasks_iam_role_description = "Example tasks IAM role for opmfront"
      tasks_iam_role_policies = {
        ReadOnlyAccess = "arn:aws:iam::aws:policy/ReadOnlyAccess"
      }
      tasks_iam_role_statements = [
        {
          actions   = ["s3:List*"]
          resources = ["arn:aws:s3:::*"]
        }
      ]

      subnet_ids = var.subnet_ids_front
      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = var.containerPort_front
          to_port                  = var.containerPort_front
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = var.source_security_group_id_front
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
  tags = var.tags
}
