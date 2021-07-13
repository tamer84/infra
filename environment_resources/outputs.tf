# ========================================
# CloudWatch & Alarms
# ========================================
output "notification_topic_arn" {
  value = module.vpp_slack_notification.this_slack_topic_arn
}

# ========================================
# API Gateway
# ========================================
output "api_gateway_domain" {
  value = aws_api_gateway_domain_name.stage-api
}

output "api_gateway_domain_com" {
  value = aws_api_gateway_domain_name.stage-api-com
}

# ========================================
# Database
# ========================================
output "docdb_parameter_group" {
  value = aws_docdb_cluster_parameter_group.vpp-docdb
}

# ========================================
# DynamoDB
# ========================================
output "vppid_mapping_table" {
  value = aws_dynamodb_table.mapping
}

# ========================================
# EventBridge
# ========================================
output "eventbus" {
  value = local.event_bus
}

output "notifications_bus" {
  value = local.notification_bus
}

# ========================================
# SQS
# ========================================
output "events_dlq" {
  value = aws_sqs_queue.vpp_dlq
}

# ========================================
# S3
# ========================================
output "resources_bucket" {
  value = aws_s3_bucket.resouces
}

output "cicd_bucket" {
  value = aws_s3_bucket.cicd_bucket
}

output "github_cert" {
  value = aws_s3_bucket_object.github_cert
}

# ========================================
# VPC
# ========================================
output "vpc" {
  value = aws_vpc.vpp
}

output "api_gateway_vpc_endpoint" {
  value = aws_vpc_endpoint.api_gateway
}

# ========================================
# Route53
# ========================================
output "local-zone" {
  value = aws_route53_zone.local
}

output "private-dns-namespace" {
  value = aws_service_discovery_private_dns_namespace.discovery
}


# ========================================
# Security groups
# ========================================
output "group_internal_access" {
  value = aws_security_group.internal_access
}

output "group_elasticsearch_access" {
  value = aws_security_group.elasticsearch_access
}

output "group_mongo_access" {
  value = aws_security_group.mongo_access
}

output "group_ssh_access" {
  value = aws_security_group.ssh_access
}

output "group_https_access" {
  value = aws_security_group.https_access
}

# ========================================
# VPC Subnets
# ========================================
output "private-subnet" {
  value = aws_subnet.private-subnet
}

output "public-subnet" {
  value = aws_subnet.public-subnet
}

# ========================================
# IAM
# ========================================
output "vpp_user_key_id" {
  value = aws_iam_access_key.vpp.id
}

output "vpp_user_key_secret" {
  value = aws_iam_access_key.vpp.secret
}

output "dynamodb_access_role" {
  value = aws_iam_role.ecs_role
}

# ========================================
# EC2
# ========================================
output "ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_instance_profile
}

# ========================================
# Glue event catalog
# ========================================
output "glue_event_database" {
  value = aws_glue_catalog_database.events_database
}