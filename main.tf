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
      Name = "${var.env}-vpc"
    }
  )
}