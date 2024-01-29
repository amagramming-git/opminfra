########################################
# Environment setting
########################################
region           = "ap-northeast-1"
app_name         = "opm"
env              = "stg"

########################################
# VPC
########################################
vpc_cidr             = "10.1.0.0/16"
azs                  = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]
enable_nat_gateway   = "true"
single_nat_gateway   = "true"