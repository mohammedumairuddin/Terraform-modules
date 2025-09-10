variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "depends_on_iam" {
  description = "IAM roles to depend on"
}
