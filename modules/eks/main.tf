resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnets_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    public_access_cidrs    = []
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator"]
  tags = {
    Name = var.cluster_name
  }

  depends_on = [var.cluster_role_dependencies]


}

# resource "local_file" "kubeconfig" {
#   content = templatefile("${path.module}/../../templates/kubeconfig.tpl", {
#     cluster_name     = aws_eks_cluster.this.name
#     cluster_endpoint = aws_eks_cluster.this.endpoint
#     ca_data          = aws_eks_cluster.this.certificate_authority[0].data
#     region           = var.aws_region
#   })
#   filename = "${path.module}/../../kubeconfig_${var.cluster_name}"
# }



resource "aws_eks_node_group" "managed_nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = var.node_group_role_arn
  subnet_ids      = var.private_subnets_ids

  scaling_config {
    desired_size = var.node_group_desired
    min_size     = var.node_group_min
    max_size     = var.node_group_max
  }

  ami_type       = "AL2_x86_64"
  instance_types = var.node_group_instance_types

  remote_access {
    ec2_ssh_key = ""
  }

  tags = {
    Name = "${var.cluster_name}-managed-node"
  }

  depends_on = [aws_eks_cluster.this]
}