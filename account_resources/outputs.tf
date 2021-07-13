# ========================================
# Global Notifications
# ========================================
output "notification_topic_arn" {
  value = module.vpp_slack_notification.this_slack_topic_arn
}

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
  value = aws_api_gateway_domain_name.vpp
}

output "api_gateway_domain_com" {
  value = aws_api_gateway_domain_name.vpp_com
}


output "aws_api_gateway_key" {
  value = aws_api_gateway_api_key.pvo-user
}

output "aws_api_gateway_vin2spec_key" {
  value = aws_api_gateway_api_key.vin2spec-user
}

# ========================================
# ACM
# ========================================
output "us_east_1_certificate" {
  value = data.aws_acm_certificate.vpp_use1
}

output "certificate" {
  value = aws_acm_certificate.vpp
}

output "certificate_com" {
  value = aws_acm_certificate.vpp_com
}

# ========================================
# Cognito
# ========================================
output "user_pool" {
  value = aws_cognito_user_pool.vpp
}

output "auth_domain" {
  value = aws_cognito_user_pool_domain.vpp
}

# ========================================
# Route53
# ========================================
output "dns" {
  value = aws_route53_zone.vpp
}

output "dns_com" {
  value = aws_route53_zone.vpp_com
}

output "dag_dns_rule" {
  value = aws_route53_resolver_rule.dag_dns_rule
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
# Transit Gateway & VPN
# ========================================
output "dag_transit_gateway" {
  value = aws_ec2_transit_gateway.dag
}

output "dag_vpn" {
  value = aws_vpn_connection.dag
}

output "dag_vpn2" {
  value = aws_vpn_connection.dag
}

output "mbio_transit_gateway" {
  value = aws_ec2_transit_gateway.mbio
}

output "mbio_vpn" {
  value = aws_vpn_connection.mbio
}

# ========================================
# CloudWatch role
# ========================================
output "vpc_flow_log_cloudwatch_access_role" {
  value = aws_iam_role.vpc_flow_log_cloudwatch_access
}

# ========================================
# Security groups
# ========================================
output "vpp_dag_all_access_sg" {
  value = aws_security_group.vpp_dag_all_access
}

# ========================================
# DAG VPC Network
# ========================================
output "vpc_dag" {
  value = aws_vpc.vpp_dag
}

output "vpc_dag_private_subnets" {
  value = aws_subnet.vpp_dag_private_subnet
}

output "vpc_dag_public_subnets" {
  value = aws_subnet.vpp_dag_public_subnet
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
output "dag_git_codestar_conn" {
  value = aws_codestarconnections_connection.daimler_git_conn
}

# ========================================
# AWS WAF
# ========================================

output "mvi_vin2spec_waf" {
  value = aws_wafv2_web_acl.mvi_vin2spec_waf_acl
}