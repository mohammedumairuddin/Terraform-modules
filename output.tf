output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_ca_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "node_group_arn" {
  value = module.eks.node_group_arn
}