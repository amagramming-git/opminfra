################################################################################
# ECS
################################################################################

variable "cluster_name" {
  description = "Name of the cluster (up to 255 letters, numbers, hyphens, and underscores)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
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

variable "target_group_arn_back" {
  type        = string
}

variable "source_security_group_id_back" {
  type        = string
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

variable "target_group_arn_front" {
  type        = string
}

variable "source_security_group_id_front" {
  type        = string
}
