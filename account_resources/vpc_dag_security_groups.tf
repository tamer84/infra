resource "aws_security_group" "vpp_dag_all_access" {
  name = "vpp_dag_all_access"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.vpp_dag.id

  tags = {
    Name        = "vpp-dag"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}