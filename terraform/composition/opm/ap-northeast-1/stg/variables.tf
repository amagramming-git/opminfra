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

variable "tags" {
  description = "A mapping of tags to assign to security group"
  type        = map(string)
  default     = {}
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