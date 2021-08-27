resource "aws_route53_zone" "mbocdp" {
  name = "${var.hosted_zone}."

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

