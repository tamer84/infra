

# ========================================
# GitHub
# ========================================
output "github_access_token" {
  value = data.external.github_access_token.result["token"]
}

# ========================================
# API Gateway
# ========================================
output "api_gateway_domain" {
  value = aws_api_gateway_domain_name.tango
  sensitive = true
}


output "aws_api_gateway_key" {
  value = aws_api_gateway_api_key.test-user
  sensitive = true
}


# ========================================
# ACM
# ========================================
output "us_east_1_certificate" {
  value = data.aws_acm_certificate.tango_use1
}

output "certificate" {
  value = aws_acm_certificate.tango
  sensitive = true
}



# ========================================
# Route53
# ========================================
output "dns" {
  value = aws_route53_zone.tango
}

# ========================================
# IAM
# ========================================
output "lambda_default_exec_role" {
  value = aws_iam_role.lambda_default_exec
}

output "cicd_role" {
  value = aws_iam_role.cicd_role
}



# ========================================
# S3
# ========================================
output "cicd_bucket" {
  value = aws_s3_bucket.cicd_bucket
}

output "github_cert" {
  value = aws_s3_bucket_object.github_cert
}

# ========================================
# CodeStar Connections
# ========================================
output "git_codestar_conn" {
  value = aws_codestarconnections_connection.git_conn
}
