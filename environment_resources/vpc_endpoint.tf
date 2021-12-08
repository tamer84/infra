resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.tango.id
  service_name = "com.amazonaws.${var.aws_region}.s3"

  private_dns_enabled = false
  route_table_ids     = aws_route_table.private-route.*.id
  vpc_endpoint_type   = "Gateway"

  depends_on = [aws_route_table.private-route]

  tags = {
    Name        = "s3endpoint-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_vpc_endpoint" "api_gateway" {
  service_name       = "com.amazonaws.${var.aws_region}.execute-api"
  vpc_id             = aws_vpc.tango.id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.internal_access.id]

  subnet_ids          = aws_subnet.private-subnet.*.id
  private_dns_enabled = true

  tags = {
    Name        = "apiendpoint-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_vpc_endpoint" "dynamo" {
  vpc_id       = aws_vpc.tango.id
  service_name = "com.amazonaws.${var.aws_region}.dynamodb"

  private_dns_enabled = false
  route_table_ids     = aws_route_table.private-route.*.id
  vpc_endpoint_type   = "Gateway"

  depends_on = [aws_route_table.private-route]

  tags = {
    Name        = "dynamoendpoint-${terraform.workspace}"
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
