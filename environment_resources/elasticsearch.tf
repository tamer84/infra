
# ========================================
# Locals
# ========================================
locals {
  es_disk_size = 100
}

resource "aws_cloudwatch_log_group" "es_log_group" {
  name = "/aws/aes/domains/tango-elastic-${terraform.workspace}/application-logs"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_log_policy" {
  policy_name     = "/aws/aes/domains/tango-elastic-${terraform.workspace}/application-logs"
  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_cloudwatch_log_group" "es_index_log_group" {
  name = "/aws/aes/domains/tango-elastic-${terraform.workspace}/index-logs"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_cloudwatch_log_group" "es_search_log_group" {
  name = "/aws/aes/domains/tango-elastic-${terraform.workspace}/search-logs"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}

resource "aws_elasticsearch_domain" "tango-es" {
  domain_name           = "tango-search-${terraform.workspace}"
  elasticsearch_version = "7.10"

  vpc_options {
    security_group_ids = [aws_security_group.internal_access.id, aws_security_group.elasticsearch_access.id]
    subnet_ids         = contains(["int", "prod"], terraform.workspace) ? aws_subnet.private-subnet.*.id : [aws_subnet.private-subnet[0].id]
  }

  cluster_config {
    instance_type          = "t3.small.elasticsearch"
    instance_count         = 1
    zone_awareness_enabled = contains(["int", "prod"], terraform.workspace) ? true : false
    zone_awareness_config {
      availability_zone_count = 2
    }
  }

  ebs_options {
    ebs_enabled = true
    volume_size = local.es_disk_size
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_index_log_group.arn
    enabled                  = true
    log_type                 = "INDEX_SLOW_LOGS"
  }
  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_search_log_group.arn
    enabled                  = true
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  access_policies = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "es:*",
      "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/tango-search-${terraform.workspace}/*"
    }
  ]
}
CONFIG

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_log_group.arn
    enabled                  = true
    log_type                 = "ES_APPLICATION_LOGS"
  }

  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
    Name        = "infra-${terraform.workspace}"
  }
}

output "tango_es" {
  value = aws_elasticsearch_domain.tango-es
}

output "es_disk_size" {
  value = local.es_disk_size
}

