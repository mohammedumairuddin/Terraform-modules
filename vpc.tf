# Get AZs if not specified
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.cluster_name}-igw" }
}

# Public subnets
resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnets_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(each.key)]
  map_public_ip_on_launch = true
  tags                    = { Name = "${var.cluster_name}-public-${each.key}" }
}

# Elastic IP for NAT
resource "aws_eip" "nat" {
  tags = { Name = "${var.cluster_name}-nat-eip" }
}

# NAT Gateway in first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "${var.cluster_name}-natgw" }
  depends_on    = [aws_internet_gateway.igw]
}

# Private subnets
resource "aws_subnet" "private" {
  for_each                = { for idx, cidr in var.private_subnets_cidrs : idx => cidr }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(each.key)]
  map_public_ip_on_launch = false
  tags                    = { Name = "${var.cluster_name}-private-${each.key}" }
}

# Route table for public subnets -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.cluster_name}-public-rt" }
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route table for private subnets -> NAT
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = { Name = "${var.cluster_name}-private-rt" }
}

resource "aws_route_table_association" "private_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# Variables
variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
}

variable "public_subnets_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster name prefix"
  type        = string
}
