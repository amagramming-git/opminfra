########################################
# Provider to connect to AWS
# https://www.terraform.io/docs/providers/aws/
########################################

terraform {
  required_version = ">= 1.7.0"
  backend "s3" {} # use backend.config for remote backend
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
