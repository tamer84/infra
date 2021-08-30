resource "aws_route53_zone" "local" {
  name = "${terraform.workspace}."

  vpc {
    vpc_id = aws_vpc.kahula.id
  }

  tags = {
    Name        = terraform.workspace
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_service_discovery_private_dns_namespace" "discovery" {
  name = "discovery.${terraform.workspace}"
  vpc  = aws_vpc.kahula.id
}

