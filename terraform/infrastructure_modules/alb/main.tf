
data "aws_route53_zone" "this" {
  name = var.route53_domain_name
}
##################################################################
# Application Load Balancer
##################################################################

module "alb" {
  source = "../../resource_modules/compute/alb"

  name    = var.alb_name
  vpc_id  = var.vpc_id
  subnets = var.subnets

  # For example only
  enable_deletion_protection = var.enable_deletion_protection

  # Security Group
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules = var.security_group_egress_rules

  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  #   prefix = "access-logs"
  # }

  # connection_logs = {
  #   bucket  = module.log_bucket.s3_bucket_id
  #   enabled = true
  #   prefix  = "connection-logs"
  # }

  listeners = {
    ex-https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = var.ssl_policy
      certificate_arn             = var.certificate_arn

      forward = {
        target_group_key = "opmfront"
      }
      rules = {
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
    }
  }

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
  # Route53 Record(s)
  route53_records = {
    A = {
      name    = var.domain_name
      type    = "A"
      zone_id = data.aws_route53_zone.this.id
    }
    AAAA = {
      name    = var.domain_name
      type    = "AAAA"
      zone_id = data.aws_route53_zone.this.id
    }
  }
  tags = var.tags
}
