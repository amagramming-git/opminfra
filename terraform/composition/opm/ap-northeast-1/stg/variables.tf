########################################
# Metadata
########################################

variable "region" {
  type = string
}

variable "app_name" {
  description = "The name of the app."
  type        = string
}

variable "env" {
  description = "The name of the environment."
  type        = string
}

variable "region_tag" {
  type = map(any)

  default = {
    "ap-northeast-1" = "tyo"
  }
}

########################################
# VPC
########################################
variable "vpc_cidr" {
  description = "(Optional) The IPv4 CIDR block for the VPC. CIDR can be explicitly set or it can be derived from IPAM using `ipv4_netmask_length` & `ipv4_ipam_pool_id`"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}


########################################
# ACM
########################################
variable "domain" {
  description = "A domain name for which the certificate should be issued"
  type        = string
  default     = ""
}
variable "route53_domain_name" {
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}

########################################
# ECR Registry
########################################
variable "create_registry_policy" {
  description = "Determines whether a registry policy will be created"
  type        = bool
  default     = false
}

variable "registry_policy" {
  description = "The policy document. This is a JSON formatted string"
  type        = string
  default     = null
}

variable "manage_registry_scanning_configuration" {
  description = "Determines whether the registry scanning configuration will be managed"
  type        = bool
  default     = false
}

variable "registry_scan_type" {
  description = "the scanning type to set for the registry. Can be either `ENHANCED` or `BASIC`"
  type        = string
  default     = "ENHANCED"
}

variable "registry_scan_rules" {
  description = "One or multiple blocks specifying scanning rules to determine which repository filters are used and at what frequency scanning will occur"
  type        = any
  default     = []
}

variable "create_registry_replication_configuration" {
  description = "Determines whether a registry replication configuration will be created"
  type        = bool
  default     = false
}

variable "registry_replication_rules" {
  description = "The replication rules for a replication configuration. A maximum of 10 are allowed"
  type        = any
  default     = []
}
################################################################################
# Repository
################################################################################

variable "repository_names" {
  description = "The name of the repository"
  type        = list(string)
  default     = []
}

variable "repository_force_delete" {
  description = "If `true`, will delete the repository even if it contains images. Defaults to `false`"
  type        = bool
  default     = null
}

variable "create_lifecycle_policy" {
  description = "Determines whether a lifecycle policy will be created"
  type        = bool
  default     = true
}

variable "repository_lifecycle_policy" {
  description = "The policy document. This is a JSON formatted string. See more details about [Policy Parameters](http://docs.aws.amazon.com/AmazonECR/latest/userguide/LifecyclePolicies.html#lifecycle_policy_parameters) in the official AWS docs"
  type        = any
  default     = {}
}
################################################################################
# Securet Manager
################################################################################

variable "securet_names" {
  description = "The name of the repository"
  type        = list(string)
  default     = []
}

################################################################################
# Load Balancer
################################################################################


variable "enable_deletion_protection_alb" {
  description = "If `true`, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to `true`"
  type        = bool
  default     = true
}

variable "ssl_policy" {
  type        = string
}

variable "fowerd_target_group_key" {
  type        = string
}

variable "target_groups" {
  description = "Map of target group configurations to create"
  type        = any
  default     = {}
}


################################################################################
# ECS
################################################################################

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "image_back" {
  description = "The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
  default     = null
}

variable "containerPort_back" {
  type        = number
}

variable "image_db" {
  description = "The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
  default     = null
}

variable "containerPort_db" {
  type        = number
}

variable "subnet_ids_back" {
  description = "List of subnets to associate with the task or service"
  type        = list(string)
  default     = []
}

variable "image_front" {
  description = "The image used to start a container. This string is passed directly to the Docker daemon. By default, images in the Docker Hub registry are available. Other repositories are specified with either `repository-url/image:tag` or `repository-url/image@digest`"
  type        = string
  default     = null
}

variable "containerPort_front" {
  type        = number
}

variable "subnet_ids_front" {
  description = "List of subnets to associate with the task or service"
  type        = list(string)
  default     = []
}