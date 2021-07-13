locals {
  zones = ["a", "b", "c"]

  subnets_cidr_blocks = {
    "private" = {
      "1" = "53.13.34.0/26"
      "2" = "53.13.34.64/26"
    }
    "public" = {
      "1" = "53.13.34.128/26"
      "2" = "53.13.34.192/26"
    }
  }
}

resource "aws_subnet" "vpp_dag_private_subnet" {
  count             = var.subnet_count
  availability_zone = "${var.aws_region}${local.zones[count.index]}"
  vpc_id            = aws_vpc.vpp_dag.id
  cidr_block        = local.subnets_cidr_blocks["private"][tostring(count.index + 1)]

  tags = {
    Name        = "private-dag-${count.index}"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_subnet" "vpp_dag_public_subnet" {
  count             = var.subnet_count
  availability_zone = "${var.aws_region}${local.zones[count.index]}"
  vpc_id            = aws_vpc.vpp_dag.id
  cidr_block        = local.subnets_cidr_blocks["public"][tostring(count.index + 1)]

  tags = {
    Name        = "public-dag-${count.index}"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_route_table_association" "vpp_dag_private_nat_association" {
  count = var.subnet_count

  subnet_id      = aws_subnet.vpp_dag_private_subnet[count.index].id
  route_table_id = aws_route_table.vpp_dag_private_route[count.index].id
}

resource "aws_route_table" "vpp_dag_private_route" {
  count = var.subnet_count

  vpc_id = aws_vpc.vpp_dag.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.vpp_dag_nat_gw[count.index].id
  }

  dynamic "route" {
    for_each = var.route_table_cidr_blocks
    content {
      cidr_block         = route.value
      transit_gateway_id = aws_ec2_transit_gateway.dag.id
    }
  }

  tags = {
    Name        = "vpp-dag-${count.index}"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}
