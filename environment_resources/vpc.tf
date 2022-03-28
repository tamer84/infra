locals {
  zones = ["a", "b", "c"]
  vpcs_cidr_blocks = {
    "dev"  = "${var.vpcs_cidr_prefix}0${var.vpcs_cidr_suffix}"
    "test" = "${var.vpcs_cidr_prefix}64${var.vpcs_cidr_suffix}"
    "int"  = "${var.vpcs_cidr_prefix}128${var.vpcs_cidr_suffix}"
    "prod" = "${var.vpcs_cidr_prefix}192${var.vpcs_cidr_suffix}"
  }
}

resource "aws_vpc" "tango" {
  cidr_block           = local.vpcs_cidr_blocks[terraform.workspace]
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "tango-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tango.id

  tags = {
    Name        = "tango-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.tango.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${terraform.workspace}-default"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

