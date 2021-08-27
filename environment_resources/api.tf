# --------- IO API ---------
resource "aws_api_gateway_domain_name" "stage-api" {
  count                    = terraform.workspace == "prod" ? 0 : 1
  domain_name              = "api.${terraform.workspace}.mbocdp.mercedes-benz.io"
  regional_certificate_arn = data.terraform_remote_state.account_resources.outputs.certificate.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api" {
  count   = terraform.workspace == "prod" ? 0 : 1
  type    = "A"
  name    = "api.${terraform.workspace}.${var.hosted_zone}"
  zone_id = data.terraform_remote_state.account_resources.outputs.dns.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_api_gateway_domain_name.stage-api[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.stage-api[0].regional_zone_id
  }
}
