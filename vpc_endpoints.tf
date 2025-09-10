# Gateway endpoint for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id, aws_route_table.public.id]
  tags              = { Name = "${var.cluster_name}-s3-endpoint" }
}

# Interface endpoints for ECR, ECR DKR, STS, and CloudWatch logs (optional)
locals {
  interface_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "sts",
    "logs", # optional; nodes may send logs
    "ec2"   # optional for some AWS SDK calls
  ]
}

resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = toset(local.interface_endpoints)
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for s in aws_subnet.private : s.id]
  security_group_ids  = [aws_security_group.endpoints_sg.id]
  private_dns_enabled = true
  tags                = { Name = "${var.cluster_name}-${each.key}-endpoint" }
}

resource "aws_security_group" "endpoints_sg" {
  name        = "${var.cluster_name}-endpoints-sg"
  description = "Security group for interface endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # allow only internal VPC
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-endpoints-sg" }
}
