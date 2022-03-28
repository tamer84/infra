resource "aws_route53_zone" "tango" {
  name = "${var.hosted_zone}."

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

