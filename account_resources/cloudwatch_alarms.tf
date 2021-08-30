locals {
  metric_namespace            = "CloudTrail"
  metric_transformation_value = "1"
  cloudtrail_log_group_name   = aws_cloudwatch_log_group.cloudtrailLogGroup.name
  alarm_comparison_operation  = "GreaterThanThreshold"
  alarm_treat_missing_data    = "notBreaching"
  alarm_threshold             = "0"
  alarm_evaluation_period     = "1"
  alarm_statistic             = "Sum"
  alarm_period                = "3600"

  alarm_list = [
    #====================================================
    #   Alarm for S3 Public Bucket creation/modification
    #====================================================
    {
      "metric_filter_name" : "S3 Public Bucket Policy Change",
      "event_name_list" : [
        "PutBucketAcl"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : ["$.requestParameters.AccessControlPolicy.AccessControlList.Grant[1].Grantee.URI=\"http://acs.amazonaws.com/groups/global/AllUsers\" || $.requestParameters.AccessControlPolicy.AccessControlList.Grant[2].Grantee.URI=\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\""],
        "log_insight_query" : ["(requestParameters.AccessControlPolicy.AccessControlList.Grant.1.Grantee.URI == \\\"http://acs.amazonaws.com/groups/global/AllUsers\\\" or requestParameters.AccessControlPolicy.AccessControlList.Grant.2.Grantee.URI == \\\"http://acs.amazonaws.com/groups/global/AuthenticatedUsers\\\")"]
      },
      "alarm_name" : "Public S3 bucket",
      "alarm_description" : "A change on bucket policy occoured, a bucket possibly turned public",
    },
    #====================================================
    #   Alarm for S3 logging and versioning change
    #====================================================
    {
      "metric_filter_name" : "S3 Bucket Logging or Versioning Change",
      "event_name_list" : [
        "PutBucketLogging",
        "PutBucketVersioning"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "S3 bucket logging or versioning changed",
      "alarm_description" : "A change on bucket logging and/or versioning policy occoured, logging/versioning might have been disabled for a bucket",
    },
    #====================================================
    #   Alarm for S3 bucket encription change
    #====================================================
    {
      "metric_filter_name" : "S3 Bucket Encription Delete",
      "event_name_list" : [
        "DeleteBucketEncription"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "S3 bucket encription settings deleted",
      "alarm_description" : "A change on bucket encription settings occoured,  at least one S3 bucket is unencripted",
    },
    #==========================================================
    #   Alarm for EC2 Instance Creation/Start/Stop/Termination
    #==========================================================
    {
      "metric_filter_name" : "EC2 State Change",
      "event_name_list" : [
        "RunInstances",
        "StartInstances",
        "StopInstances",
        "TerminateInstances"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "EC2 instance state changed",
      "alarm_description" : "A change on an EC2 instance ocourred, one or more instances were deployed/started or stopped/terminated",
    },
    #==========================================================
    #   Alarm for Failed login
    #==========================================================
    {
      "metric_filter_name" : "Failed Login",
      "event_name_list" : [
        "ConsoleLogin"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : ["$.responseElements.ConsoleLogin != \"Success\""],
        "log_insight_query" : ["responseElements.ConsoleLogin != 'Success'"]
      },
      "alarm_name" : "Login attept failed",
      "alarm_description" : "A IAM attempt failed",
    },
    #==========================================================
    #   Alarm for account creation
    #==========================================================
    {
      "metric_filter_name" : "Account Creation",
      "event_name_list" : [
        "CreateAccount"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "Account created",
      "alarm_description" : "A new IAM account was created",
    },
    #==========================================================
    #   Alarm for IAM policy creation
    #==========================================================
    {
      "metric_filter_name" : "IAM Policy Creation",
      "event_name_list" : [
        "CreatePolicy"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "IAM policy created",
      "alarm_description" : "A new IAM policy was created",
    },
    #==========================================================
    #   Alarm for User access key creation
    #==========================================================
    {
      "metric_filter_name" : "Access Key Creation Or Update",
      "event_name_list" : [
        "CreateAccessKey",
        "UpdateAccessKey"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "Access key created or updated",
      "alarm_description" : "A new IAM user access key was created or updated",
    },
    #==========================================================
    #   Alarm for Policy attachment
    #==========================================================
    {
      "metric_filter_name" : "IAM Policy Attachment",
      "event_name_list" : [
        "AttachGroupPolicy",
        "AttachRolePolicy",
        "AttachUserPolicy",
        "AttachPolicy"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "IAM policy attached",
      "alarm_description" : "A IAM policy was attached to a group, role or user ",
    },
    #==========================================================
    #   Alarm for Inline Policy attachment
    #==========================================================
    {
      "metric_filter_name" : "IAM Inline Policy Attachment",
      "event_name_list" : [
        "PutUserPolicy",
        "PutGroupPolicy",
        "PutRolePolicy"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "Inline policy attached",
      "alarm_description" : "A inline policy was attached to a group, role or user ",
    },
    #==========================================================
    #   Alarm for user addition to a group
    #==========================================================
    {
      "metric_filter_name" : "User add to a group",
      "event_name_list" : [
        "AddUserToGroup",
        "AddUsersToGroup"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "User added to group",
      "alarm_description" : "One or more users were added to a group",
    },
    #==========================================================
    #   Alarm for Systems Manager Session start
    #==========================================================
    {
      "metric_filter_name" : "SSM Session Start",
      "event_name_list" : [
        "StartSession",
        "ResumeSession"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "Systems Manager Session started",
      "alarm_description" : "One or more Systems Manager Sessions were started",
    },
    #==========================================================
    #   Alarm for System log deletion or tampering (Update)
    #==========================================================
    {
      "metric_filter_name" : "CloudWatch log delete",
      "event_name_list" : [
        "DeleteDestination",
        "DeleteLogGroup",
        "DeleteLogStream",
        "DeleteRetentionPolicy"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "CloudWatch log deleted",
      "alarm_description" : "CloudWatch logs might have been tampered or  deleted",
    },
    #==========================================================
    #   Alarm for CW Alarm deletion
    #==========================================================
    {
      "metric_filter_name" : "CloudWatch alarm change",
      "event_name_list" : [
        "DisableAlarmActions",
        "PutAlarmWithState",
        "PutMetricAlarm",
        "SetAlarmState",
        "DeleteAlarms"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "CloudWatch alarms changed",
      "alarm_description" : "CloudWatch alarms might have been tampered or changed",
    },
    #==========================================================
    #   Alarm for DynamoDB Index deletion
    #==========================================================
    {
      "metric_filter_name" : "DynamoDB index change",
      "event_name_list" : [
        "DeleteTable"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : ["$.requestParameters.globalSecondaryIndexUpdates[0].delete.indexName = \"*\""],
        "log_insight_query" : ["ispresent(requestParameters.globalSecondaryIndexUpdates.0.delete.indexName)"]
      },
      "alarm_name" : "DynamoDB Index deleted",
      "alarm_description" : "DynamoDB might have been improperly deleted",
    },
    #==========================================================
    #   Alarm for DynamoDB Table deletion
    #==========================================================
    {
      "metric_filter_name" : "DynamoDB table delete",
      "event_name_list" : [
        "DeleteTable"
      ],
      "additional_filter_pattern" : {
        "metric_filter_query" : [],
        "log_insight_query" : []
      },
      "alarm_name" : "DynamoDB table deleted",
      "alarm_description" : "DynamoDB table might have been improperly deleted",
    }
  ]
}


resource "aws_cloudwatch_log_metric_filter" "metric_filter" {
  count = length(local.alarm_list)

  name           = local.alarm_list[count.index].metric_filter_name
  pattern        = <<EOT
{
  %{for event_index, event_name in local.alarm_list[count.index].event_name_list}
    $.eventName = "${event_name}"
    %{if length(local.alarm_list[count.index].event_name_list) - 1 != event_index}
      ||
    %{endif}
  %{endfor}
  %{for query in local.alarm_list[count.index].additional_filter_pattern.metric_filter_query}
    && ${query}
  %{endfor}
}
  EOT
  log_group_name = local.cloudtrail_log_group_name

  metric_transformation {
    name      = local.alarm_list[count.index].metric_filter_name
    namespace = local.metric_namespace
    value     = local.metric_transformation_value
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm" {
  count = length(local.alarm_list)

  alarm_name        = "aws-${local.alarm_list[count.index].alarm_name}"
  alarm_description = local.alarm_list[count.index].alarm_description
  metric_name       = local.alarm_list[count.index].metric_filter_name

  comparison_operator = local.alarm_comparison_operation
  evaluation_periods  = local.alarm_evaluation_period
  namespace           = local.metric_namespace
  period              = local.alarm_period
  statistic           = local.alarm_statistic
  threshold           = local.alarm_threshold
  treat_missing_data  = local.alarm_treat_missing_data
}
