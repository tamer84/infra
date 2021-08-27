variable "domains" {
  type = list(any)
  default = [
    "mbocdp.mercedes-benz.io",
    "*.mbocdp.mercedes-benz.io",
    "*.dev.mbocdp.mercedes-benz.io",
    "*.test.mbocdp.mercedes-benz.io",
    "*.prod.mbocdp.mercedes-benz.io",
    "*.int.mbocdp.mercedes-benz.io"
  ]
}

# --------- IO CERTIFICATE ---------
resource "aws_acm_certificate" "mbocdp" {
  domain_name               = var.domains[0]
  subject_alternative_names = slice(var.domains, 1, length(var.domains))

  validation_method = "DNS"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }

  lifecycle {
    ignore_changes = [subject_alternative_names]
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.mbocdp.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  # count           = length(var.domains)
  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.mbocdp.zone_id
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.mbocdp.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Find a certificate that is issued
data "aws_acm_certificate" "mbocdp_use1" {
  domain   = "mbocdp.mercedes-benz.io"
  statuses = ["ISSUED"]

  provider = aws.use1
}

