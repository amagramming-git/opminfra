variable "domain_name" {
  description = "The domain name for which the certificate should be issued"
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}

variable "route53_domain_name" {
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}

variable "alb_name" {
  description = "The name of the LB. This name must be unique within your AWS account, can have a maximum of 32 characters, must contain only alphanumeric characters or hyphens, and must not begin or end with a hyphen"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "Identifier of the VPC where the security group will be created"
  type        = string
  default     = null
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type `network`. Changing this value for load balancers of type `network` will force a recreation of the resource"
  type        = list(string)
  default     = null
}

variable "enable_deletion_protection" {
  description = "If `true`, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to `true`"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "target_groups" {
  description = "Map of target group configurations to create"
  type        = any
  default     = {}
}
variable "listener_rules" {
  type        = any
  default     = {}
}
variable "fowerd_target_group_key" {
  type        = string
}
variable "certificate_arn" {
  type        = string
}
variable "ssl_policy" {
  type        = string
}
variable "vpc_cidr_block" {
  type        = string
}