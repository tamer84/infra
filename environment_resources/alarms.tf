
resource "aws_cloudwatch_metric_alarm" "dead_letter_messages" {
  alarm_name          = "failures-queue-${terraform.workspace}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "NumberOfMessagesReceived"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "New messages on Dead Letter Queue!"
  datapoints_to_alarm = 1
  treat_missing_data  = "notBreaching"
  dimensions = {
    "QueueName" = "failures-${terraform.workspace}"
  }
}
