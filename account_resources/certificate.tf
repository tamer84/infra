variable "domains" {
  type = list(any)
  default = [
    "vpp.mercedes-benz.io",
    "*.vpp.mercedes-benz.io",
    "*.dev.vpp.mercedes-benz.io",
    "*.test.vpp.mercedes-benz.io",
    "*.prod.vpp.mercedes-benz.io",
    "*.int.vpp.mercedes-benz.io"
  ]
}

# --------- IO CERTIFICATE ---------
resource "aws_acm_certificate" "vpp" {
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
    for dvo in aws_acm_certificate.vpp.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  # count           = length(var.domains)
  name    = each.value.name
  type    = each.value.type
  zone_id = aws_route53_zone.vpp.zone_id
  records = [each.value.record]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.vpp.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Find a certificate that is issued
data "aws_acm_certificate" "vpp_use1" {
  domain   = "vpp.mercedes-benz.io"
  statuses = ["ISSUED"]

  provider = aws.use1
}

# --------- COM CERTIFICATE ---------
resource "aws_acm_certificate" "vpp_com" {
  private_key       = base64decode(data.external.certificate_com.result["cert_priv_key"])
  certificate_body  = base64decode(data.external.certificate_com.result["cert_body"])
  certificate_chain = base64decode(data.external.certificate_com.result["cert_chain"])

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

# # Find a certificate that is issued
data "aws_acm_certificate" "vpp_com_use1" {
  domain   = "vpp.mercedes-benz.com"
  statuses = ["ISSUED"]

  provider = aws.use1
}
