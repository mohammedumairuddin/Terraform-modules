resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }

  depends_on = [var.depends_on_iam]
}

resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
}
