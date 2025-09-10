module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidrs = var.public_subnets_cidrs
  private_subnets_cidrs = var.private_subnets_cidrs
  availability_zones   = var.availability_zones
  cluster_name         = var.cluster_name
}

module "security_groups" {
  source   = "./modules/security_groups"
  cluster_name = var.cluster_name
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

module "eks" {
  source                  = "./modules/eks"
  cluster_name            = var.cluster_name
  cluster_version         = var.cluster_version
  cluster_role_arn        = module.iam.cluster_role_arn
  cluster_role_dependencies = [module.iam.eks_cluster_role]
  node_group_role_arn    = module.iam.node_group_role_arn
  private_subnets_ids     = module.vpc.private_subnets_ids
  node_group_instance_types = var.node_group_instance_types
  node_group_desired      = var.node_group_desired
  node_group_min          = var.node_group_min
  node_group_max          = var.node_group_max
  aws_region              = var.aws_region
}

module "vpc_endpoints" {
  source               = "./modules/vpc_endpoints"
  cluster_name         = var.cluster_name
  vpc_id               = module.vpc.vpc_id
  aws_region           = var.aws_region
  route_table_private_id = module.vpc.route_table_private_id
  route_table_public_id = module.vpc.route_table_public_id
  private_subnets_ids   = module.vpc.private_subnets_ids
  vpc_cidr              = var.vpc_cidr
}