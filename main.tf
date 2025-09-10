
module "vpc" {
  source          = "./modules/vpc"
  cluster_name    = var.cluster_name
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
  cluster_name = var.cluster_name
}


module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
}

module "eks" {
  source               = "./modules/eks"
  cluster_name         = var.cluster_name
  subnet_ids           = module.vpc.private_subnet_ids
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  node_role_arn        = module.iam.node_role_arn
  security_group_ids   = [module.security_groups.eks_sg_id]
  depends_on_iam       = [module.iam]
}
