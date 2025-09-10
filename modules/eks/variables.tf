variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "cluster_role_dependencies" {
  description = "Dependencies for EKS cluster (IAM roles etc.)"
  type        = list(any)
  default     = []
}


variable "node_group_role_arn" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "node_group_instance_types" {
  type = list(string)
}

variable "node_group_desired" {
  type = number
}

variable "node_group_min" {
  type = number
}

variable "node_group_max" {
  type = number
}

variable "aws_region" {
  type = string
}