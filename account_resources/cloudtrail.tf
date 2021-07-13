locals {
  cicd_bucket  = "arn:aws:s3:::vpp-cicd"
  environments = ["dev", "test", "int", "prod"]
  mvi_patterns = ["mvi", "mvi-admin", "dashboard", "aggregator", "microgateway", "streamlit"]
  cloudtrail_data_resources = flatten([
    for environment in toset(local.environments) : flatten([
      for pattern in toset(local.mvi_patterns) : [
        "${local.cicd_bucket}-${environment}/${pattern}-${environment}",
        "${local.cicd_bucket}-${environment}/${pattern}-${environment}/*"
      ]
    ])
  ])
}

resource "aws_cloudwatch_log_group" "cloudtrailLogGroup" {
  name = "vpp-cloudtrail-logs"
}

resource "aws_cloudtrail" "cloudtrail" {
  name                       = "vpp-cloudtrail"
  s3_bucket_name             = aws_s3_bucket.cloudtrail_bucket.id
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrailLogGroup.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_role.arn
  depends_on                 = [aws_s3_bucket.cloudtrail_bucket, aws_s3_bucket_policy.cloudtrail_bucket_policy]

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = local.cloudtrail_data_resources
    }
  }
}
