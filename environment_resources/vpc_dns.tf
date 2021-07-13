resource "aws_route53_zone" "local" {
  name = "${terraform.workspace}."

  vpc {
    vpc_id = aws_vpc.vpp.id
  }

  tags = {
    Name        = terraform.workspace
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_service_discovery_private_dns_namespace" "discovery" {
  name = "discovery.${terraform.workspace}"
  vpc  = aws_vpc.vpp.id
}

resource "aws_route53_resolver_endpoint" "dag_resolver" {
  name      = "vpp-${terraform.workspace}"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.internal_access.id]

  dynamic "ip_address" {
    for_each = aws_subnet.private-subnet
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_route53_resolver_rule_association" "dag_dns_resolver_association" {
  resolver_rule_id = data.terraform_remote_state.account_resources.outputs.dag_dns_rule.id
  vpc_id           = aws_vpc.vpp.id
}
