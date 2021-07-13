resource "aws_route53_zone" "vpp" {
  name = "${var.hosted_zone}."

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_route53_zone" "vpp_com" {
  name = "${var.hosted_zone_com}."

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

# INBOUND ENDPOINTS CREATED IN ENVIRONMENT RESOURCES
resource "aws_route53_resolver_endpoint" "dag" {
  name      = "dag"
  direction = "OUTBOUND"

  security_group_ids = [
    aws_security_group.vpp_dag_all_access.id
  ]

  dynamic "ip_address" {
    for_each = aws_subnet.vpp_dag_private_subnet
    content {
      subnet_id = ip_address.value.id
    }
  }

  dynamic "ip_address" {
    for_each = aws_subnet.vpp_dag_public_subnet
    content {
      subnet_id = ip_address.value.id
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_route53_resolver_rule" "dag_dns_rule" {
  domain_name          = "corpintra.net"
  name                 = "dag_dns"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.dag.id

  target_ip {
    ip = var.dag_dns_server
  }

  tags = {
    Terraform   = "true"
    Environment = "vpp-dag"
  }
}

resource "aws_route53_resolver_rule_association" "dag_dns_resolver_association" {
  resolver_rule_id = aws_route53_resolver_rule.dag_dns_rule.id
  vpc_id           = aws_vpc.vpp_dag.id
}
