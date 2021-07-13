locals {
  dag_vpc_cidr_block = "53.13.34.0/24"
}

resource "aws_vpc" "vpp_dag" {
  cidr_block           = local.dag_vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Terraform   = "true"
    Name        = "vpp-dag"
    Environment = "vpp-dag"
  }
}

resource "aws_internet_gateway" "vpp_dag_igw" {
  vpc_id = aws_vpc.vpp_dag.id

  tags = {
    Name        = "vpp-dag"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_eip" "vpp_dag_public_ip" {
  count = var.subnet_count
  vpc   = true
  tags = {
    Name        = "vpp-dag-${count.index}"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_default_route_table" "vpp_dag_default" {
  default_route_table_id = aws_vpc.vpp_dag.default_route_table_id

  dynamic "route" {
    for_each = var.route_table_cidr_blocks
    content {
      cidr_block         = route.value
      transit_gateway_id = aws_ec2_transit_gateway.dag.id
    }
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpp_dag_igw.id
  }

  tags = {
    Name        = "vpp-dag-default"
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_cloudwatch_log_group" "vpp_dag_flow_log" {
  name = "vpc_dag_flow_log"
  tags = {
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_flow_log" "vpp_dag_flow_log_cw" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_cloudwatch_access.arn
  log_destination = aws_cloudwatch_log_group.vpp_dag_flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.vpp_dag.id

  tags = {
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}
