# --------- DNS API --------

resource "aws_api_gateway_domain_name" "tango" {
  domain_name              = "api.tamer84.eu"
  regional_certificate_arn  = data.aws_acm_certificate.tango.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api" {
  type    = "A"
  name    = "api.${var.hosted_zone}"
  zone_id = aws_route53_zone.tango.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.tango.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.tango.regional_zone_id
  }
}


resource "aws_api_gateway_api_key" "test-user" {
  name = "test_user"
}
