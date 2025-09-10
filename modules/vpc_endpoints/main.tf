resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_private_id, var.route_table_public_id]
  tags              = { Name = "${var.cluster_name}-s3-endpoint" }
}

locals {
  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "sts",
    "logs",
    "ec2"
  ]
}

resource "aws_security_group" "endpoints_sg" {
  name        = "${var.cluster_name}-endpoints-sg"
  description = "Security group for interface endpoints"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-endpoints-sg" }
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = toset(local.interface_endpoints)
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets_ids
  security_group_ids  = [aws_security_group.endpoints_sg.id]
  private_dns_enabled = true
  tags                = { Name = "${var.cluster_name}-${each.key}-endpoint" }
}