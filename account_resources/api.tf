# --------- IO API --------
# as soon as we have an account we need to register a Certificate from AWS
# which will send an email to the nebula team for confirmation that we are allowed to use *.mercedes-benz.io
# then we can setup the info here
# that's a manual step, as it requires verification
resource "aws_api_gateway_domain_name" "mbocdp" {
  domain_name              = "api.mbocdp.mercedes-benz.io"
  regional_certificate_arn  = aws_acm_certificate.mbocdp.arn
}

resource "aws_route53_record" "api" {
  type    = "A"
  name    = "api.${var.hosted_zone}"
  zone_id = aws_route53_zone.mbocdp.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.mbocdp.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.mbocdp.regional_zone_id
  }
}


resource "aws_api_gateway_api_key" "test-user" {
  name = "test_user"
}
