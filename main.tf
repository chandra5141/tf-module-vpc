resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,{
      Name = "${var.env}-vpc"
    }
  )
}


resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnets_cidr)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnets_cidr[count.index]

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-public_subnet${count.index+1}"
    }
  )
}


resource "aws_subnet" "private_subnet" {
  count      = length(var.private_subnets_cidr)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_subnets_cidr[count.index]

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-private_subnet${count.index+1}"
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


resource "aws_route_table" "public_route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = data.aws_caller_identity.vpc_owner_id.id
    vpc_peering_connection_id = aws_vpc_peering_connection.aws_vpc_connection.id
  }

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-public_route_table"
    }
  )
}

resource "aws_route_table_association" "public_rt_association" {
  count = length(aws_route_table.public_route-table)
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_route-table.id
}

resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "naw" {
  subnet_id = aws_subnet.public_subnet.*.id[0]
  allocation_id = aws_eip.eip.allocation_id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-igw"
    }
  )
}


resource "aws_route_table" "private_route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.naw.id
  }

  route {
    cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.aws_vpc_connection.id
  }

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-private_route_table"
    }
  )
}

resource "aws_route_table_association" "private_rt_association" {
  count = length(aws_route_table.private_route-table)
  subnet_id = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_route-table.id
}

