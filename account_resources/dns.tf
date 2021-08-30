resource "aws_route53_zone" "kahula" {
  name = "${var.hosted_zone}."

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

