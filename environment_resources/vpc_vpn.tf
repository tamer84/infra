resource "aws_ec2_transit_gateway_vpc_attachment" "mbio" {
  subnet_ids         = aws_subnet.private-subnet.*.id
  transit_gateway_id = data.terraform_remote_state.account_resources.outputs.mbio_transit_gateway.id
  vpc_id             = aws_vpc.vpp.id

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "mbio"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "dag" {
  subnet_ids         = aws_subnet.private-subnet.*.id
  transit_gateway_id = data.terraform_remote_state.account_resources.outputs.dag_transit_gateway.id
  vpc_id             = aws_vpc.vpp.id

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "dag"
  }
}
