
# ========================================
# Locals
# ========================================
locals {
  es_disk_size = 100
}

resource "aws_elasticsearch_domain" "kahula-es" {
  domain_name           = "kahula-search-${terraform.workspace}"
  elasticsearch_version = "7.10"

  vpc_options {
    security_group_ids = [data.terraform_remote_state.environment_resources.outputs.group_internal_access.id, data.terraform_remote_state.environment_resources.outputs.group_elasticsearch_access.id]
    subnet_ids         = contains(["int", "prod"], terraform.workspace) ? data.terraform_remote_state.environment_resources.outputs.private-subnet.*.id : [data.terraform_remote_state.environment_resources.outputs.private-subnet[0].id]
  }

  cluster_config {
    instance_type          = "c6g.xlarge.elasticsearch"
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
      "Resource": "arn:aws:es:${var.aws_region}:${data.aws_caller_identity.current.account_id}:domain/kahula-search-${terraform.workspace}/*"
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
    Name        = "${var.application_name}-${terraform.workspace}"
  }
}

output "kahula_es" {
  value = aws_elasticsearch_domain.kahula-es
}

output "es_disk_size" {
  value = local.es_disk_size
}

