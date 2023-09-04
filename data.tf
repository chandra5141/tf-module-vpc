data "aws_caller_identity" "vpc_owner_id" {}
data "aws_vpc" "default" {
  id = var.default_vpc_id
}