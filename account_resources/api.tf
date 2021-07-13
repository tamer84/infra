# --------- IO API ---------
resource "aws_api_gateway_domain_name" "vpp" {
  domain_name              = "api.vpp.mercedes-benz.io"
  regional_certificate_arn = aws_acm_certificate.vpp.arn
}

resource "aws_route53_record" "api" {
  type    = "A"
  name    = "api.${var.hosted_zone}"
  zone_id = aws_route53_zone.vpp.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.vpp.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.vpp.regional_zone_id
  }
}

# --------- COM API ---------
resource "aws_api_gateway_domain_name" "vpp_com" {
  domain_name              = "api.vpp.mercedes-benz.com"
  regional_certificate_arn = aws_acm_certificate.vpp_com.arn
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api_com" {
  type    = "A"
  name    = "api.${var.hosted_zone_com}"
  zone_id = aws_route53_zone.vpp_com.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.vpp_com.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.vpp_com.regional_zone_id
  }
}


resource "aws_api_gateway_api_key" "pvo-user" {
  name = "pvo_user"
}

resource "aws_api_gateway_api_key" "vin2spec-user" {
  name = "vin2spec_user"
}
