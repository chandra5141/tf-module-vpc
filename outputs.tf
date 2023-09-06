output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
}

output "vpc_peering_id" {
  value = aws_vpc_peering_connection.aws_vpc_connection.id
}