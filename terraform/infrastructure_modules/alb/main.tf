
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
  security_group_ingress_rules = {
      all_https = {
        from_port   = 443
        to_port     = 443
        ip_protocol = "tcp"
        description = "HTTPS web traffic"
        cidr_ipv4   = "0.0.0.0/0"
      }
    }
  security_group_egress_rules = {
      all = {
        ip_protocol = "-1"
        cidr_ipv4   = var.vpc_cidr_block
      }
    }

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
        target_group_key = var.fowerd_target_group_key
      }
      rules = var.listener_rules
    }
  }
  target_groups = var.target_groups
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
