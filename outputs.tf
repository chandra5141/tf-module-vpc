output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.aws_vpc_connection.id
}

output "public_subnet_ids" {
  value = module.public_subnets
}


output "private_subnet_ids" {
  value = module.private_subnets
}