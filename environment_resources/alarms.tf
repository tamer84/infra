module "vpp_slack_notification" {
  source  = "terraform-aws-modules/notify-slack/aws"
  version = "~> 4.0"

  sns_topic_name = "vpp_alerts_${terraform.workspace}"

  lambda_function_name = "vpp-notification-${terraform.workspace}"

  slack_webhook_url = var.slack_url
  slack_channel     = "p-vpp-notifications-${terraform.workspace}"
  slack_username    = "vpp-infra-alerts"
  slack_emoji       = ":alert:"
}

resource "aws_cloudwatch_metric_alarm" "dead_letter_messages" {
  alarm_name          = "vpp-failures-queue-${terraform.workspace}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfMessagesReceived"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "New messages on Dead Letter Queue!"
  alarm_actions       = [module.vpp_slack_notification.this_slack_topic_arn]
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"
  dimensions = {
    "QueueName" = "vpp-failures-${terraform.workspace}"
  }
}

# Alarm does not supports more than 10 metrics
//resource "aws_cloudwatch_metric_alarm" "lambda_erros" {
//  alarm_name                = "vpp-lambda-erros-${terraform.workspace}"
//  comparison_operator       = "GreaterThanThreshold"
//  evaluation_periods        = "1"
//  threshold                 = "5"
//  alarm_description         = "Notify when lambdas are throwing too many errors"
//  alarm_actions             = [module.vpp_slack_notification.this_slack_topic_arn]
//  datapoints_to_alarm       = 1
//
//  dynamic "metric_query" {
//    for_each = var.registered_functions
//
//    content {
//      id = "m${metric_query.key + 1}"
//      return_data = false
//      metric {
//        dimensions  = {
//          "FunctionName" = "vpp-${metric_query.value}-${terraform.workspace}"
//        }
//        metric_name = "Errors"
//        namespace   = "AWS/Lambda"
//        period      = 60
//        stat        = "Average"
//      }
//    }
//  }
//
//  metric_query {
//    expression  = "AVG(METRICS())"
//    id          = "e1"
//    label       = "ErrorsAverage"
//    return_data = true
//  }
//}