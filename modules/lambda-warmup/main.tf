resource "aws_cloudwatch_event_rule" "rule" {
  name                  = var.event_rule_name
  description           = "Fires every one minute"
  schedule_expression   = var.rate
}

resource "aws_cloudwatch_event_target" "call_lambda_every_one_minute" {
  rule  = aws_cloudwatch_event_rule.rule.name
  arn   = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  statement_id    = "AllowExecutionFromCloudWatch_${var.event_rule_name}"
  action          = "lambda:InvokeFunction"
  function_name   = var.lambda_function_name
  principal       = "events.amazonaws.com"
  source_arn      = aws_cloudwatch_event_rule.rule.arn
}
