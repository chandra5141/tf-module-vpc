resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,{
      Name = "${var.env}-vpc"
    }
  )
}

resource "aws_vpc_peering_connection" "aws_vpc_connection" {
  peer_owner_id = data.aws_caller_identity.vpc_owner_id.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.vpc.id
  auto_accept = true

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-vpc_peering_connection"
    }
  )
}

resource "aws_route" "route_for_vpc_peering_created" {

  route_table_id = data.aws_vpc.default.main_route_table_id
  destination_cidr_block = var.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.aws_vpc_connection.id
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-igw" }
  )
}

resource "aws_eip" "ngw-eip" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.ngw-eip.id
  subnet_id     = lookup(lookup(module.public_subnets, "public", null), "subnet_ids", null)[0]

  tags = merge(
    local.common_tags,
    { Name = "${var.env}-ngw" }
  )

}
