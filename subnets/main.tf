resource "aws_subnet" "main_subnet" {
  count = length(var.cidr_block)
  cidr_block = var.cidr_block[count.index]
  availability_zone = var.availability_zone[count.index]
  vpc_id = var.vpc_id

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-${var.name}-subnet-${count.index+1}"
    }
  )
}

resource "aws_route_table" "route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block        = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = var.vpc_peering_connection_id
  }

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-${var.name}-routetable"
    }
  )

}

resource "aws_route_table_association" "rt_association_subnet" {
  count = length(aws_subnet.main_subnet)
  subnet_id      = aws_subnet.main_subnet.*.id[count.index]
  route_table_id = aws_route_table.route_table.id
}

resource "aws_route" "igw_route" {
  count                  = var.internet_gw ? 1 : 0
  gateway_id = var.internet_gw
  route_table_id = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route" "nat_gw_route" {
  count                  = var.nat_gw ? 1 : 0
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gw_id
}