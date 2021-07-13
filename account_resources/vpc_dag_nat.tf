resource "aws_nat_gateway" "vpp_dag_nat_gw" {
  count = var.subnet_count

  allocation_id = aws_eip.vpp_dag_public_ip[count.index].id
  subnet_id     = aws_subnet.vpp_dag_public_subnet[count.index].id

  tags = {
    Name        = "vpp-dag-${count.index}"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}
