variable "vpc_id" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "route_table_private_id" {
  type = string
}

variable "route_table_public_id" {
  type = string
}

variable "private_subnets_ids" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}