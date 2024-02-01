# https://github.com/terraform-aws-modules/terraform-aws-acm/blob/master/examples/complete-dns-validation/main.tf
# 20240201
# 当システム用に大幅に編集しております。

locals {
  # Removing trailing dot from domain - just to be sure
  domain_name = trimsuffix(var.domain, ".") 
}

##########################################################
# Example 1 (default case):
# Using one AWS provider for both ACM and Route53 records
##########################################################

data "aws_route53_zone" "this" {
  count = 1
  name         = local.domain_name
  private_zone = false
}

module "acm" {
  source = "../../resource_modules/security/acm"

  domain_name = local.domain_name
  zone_id     = data.aws_route53_zone.this[0].zone_id

  validation_method = "DNS"

  tags = {
    Name = local.domain_name
  }
}