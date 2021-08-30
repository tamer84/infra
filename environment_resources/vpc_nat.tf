resource "aws_eip" "public-ip" {
  count = var.subnet_count
  vpc   = true
  tags = {
    Name        = "${terraform.workspace}-${count.index}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count         = var.subnet_count
  allocation_id = aws_eip.public-ip[count.index].id
  subnet_id     = aws_subnet.public-subnet[count.index].id

  tags = {
    Name        = "${terraform.workspace}-${count.index}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_route_table_association" "private-nat" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.private-subnet[count.index].id
  route_table_id = aws_route_table.private-route[count.index].id
}

resource "aws_route_table" "private-route" {
  count  = var.subnet_count
  vpc_id = aws_vpc.kahula.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw[count.index].id
  }

  dynamic "route" {
    for_each = var.mbio_subnet
    content {
      cidr_block         = route.value
      transit_gateway_id = data.terraform_remote_state.account_resources.outputs.mbio_transit_gateway.id
    }
  }

  tags = {
    Name        = "${terraform.workspace}-${count.index}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
