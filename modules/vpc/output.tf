output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnets_ids" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnets_ids" {
  value = [for subnet in aws_subnet.private : subnet.id]
}

output "route_table_public_id" {
  value = aws_route_table.public.id
}

output "route_table_private_id" {
  value = aws_route_table.private.id
}