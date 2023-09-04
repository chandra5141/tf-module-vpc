resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  tags = merge(
    local.common_tags,{
      Name = "${var.env}-vpc"
    }
  )
}

resource "aws_subnet" "main" {
  count      = length(var.subnets_cidr)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnets_cidr[count.index]

  tags = merge(
    local.common_tags,{
      Name = "${var.env}-subnets${count.index+1}"
    }
  )
}

resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = data.aws_caller_identity.vpc_owner_id.account_id
  peer_vpc_id   = "vpc-024f86141cbbc02e6"
  vpc_id        = aws_vpc.vpc.id
  auto_accept = true
  tags = merge(
    local.common_tags,{
      Name = "${var.env}-vpc_peering_connection${count.index+1}"
    }
  )
}