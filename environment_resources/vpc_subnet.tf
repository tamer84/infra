locals {
  subnets_cidr_blocks = {
    "dev" = {
      "private" = {
        "1" = "${var.vpcs_cidr_prefix}0${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}16${var.subnets_cidr_suffix}"
      }
      "public" = {
        "1" = "${var.vpcs_cidr_prefix}32${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}48${var.subnets_cidr_suffix}"
      }
    },
    "test" = {
      "private" = {
        "1" = "${var.vpcs_cidr_prefix}64${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}80${var.subnets_cidr_suffix}"
      }
      "public" = {
        "1" = "${var.vpcs_cidr_prefix}96${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}112${var.subnets_cidr_suffix}"
      }
    },
    "int" = {
      "private" = {
        "1" = "${var.vpcs_cidr_prefix}128${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}144${var.subnets_cidr_suffix}"
      }
      "public" = {
        "1" = "${var.vpcs_cidr_prefix}160${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}176${var.subnets_cidr_suffix}"
      }
    },
    "prod" = {
      "private" = {
        "1" = "${var.vpcs_cidr_prefix}192${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}208${var.subnets_cidr_suffix}"
      }
      "public" = {
        "1" = "${var.vpcs_cidr_prefix}224${var.subnets_cidr_suffix}"
        "2" = "${var.vpcs_cidr_prefix}240${var.subnets_cidr_suffix}"
      }
    }
  }
}

resource "aws_subnet" "private-subnet" {
  count             = var.subnet_count
  availability_zone = "${var.aws_region}${local.zones[count.index]}"
  vpc_id            = aws_vpc.kahula.id
  cidr_block        = local.subnets_cidr_blocks[terraform.workspace]["private"][tostring(count.index + 1)]

  tags = {
    Name        = "private-${terraform.workspace}-${count.index}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_subnet" "public-subnet" {
  count             = var.subnet_count
  availability_zone = "${var.aws_region}${local.zones[count.index]}"
  vpc_id            = aws_vpc.kahula.id
  cidr_block        = local.subnets_cidr_blocks[terraform.workspace]["public"][tostring(count.index + 1)]

  tags = {
    Name        = "public-${terraform.workspace}-${count.index}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
