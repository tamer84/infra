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
  vpc_id = aws_vpc.tango.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw[count.index].id
  }


  tags = {
    Name        = "${terraform.workspace}-${count.index}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
