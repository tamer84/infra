resource "aws_cognito_user_pool" "vpp" {
  name = "vpp"

  mfa_configuration          = "OFF"
  sms_authentication_message = "Your authentication code is {####}. "

  auto_verified_attributes = [
    "email",
  ]

  username_attributes = [
    "email",
  ]

  admin_create_user_config {
    allow_admin_create_user_only = true

    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}. "
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}. "
    }
  }

  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    source_arn            = "arn:aws:ses:eu-west-1:736578946942:identity/admin@vpp.mercedes-benz.io"
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_message        = "Your verification code is {####}. "
    email_subject        = "Your verification code"
    sms_message          = "Your verification code is {####}. "
  }
}

resource "aws_cognito_user_pool_domain" "vpp" {
  domain          = "auth.vpp.mercedes-benz.io"
  user_pool_id    = aws_cognito_user_pool.vpp.id
  certificate_arn = "arn:aws:acm:us-east-1:736578946942:certificate/c060fe37-300f-4301-905c-c220c9457567"
}

resource "aws_route53_record" "auth" {
  zone_id = aws_route53_zone.vpp.zone_id
  name    = "auth.vpp.mercedes-benz.io"
  type    = "A"

  alias {
    name                   = aws_cognito_user_pool_domain.vpp.cloudfront_distribution_arn
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}
