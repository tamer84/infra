
data "aws_caller_identity" "current" {}

resource "aws_lambda_permission" "allow_cloudwatch" {
  //Only created when the target is a lambda
  // This allows the lambda created above to receive events from eventbridge https://www.terraform.io/docs/providers/aws/r/lambda_permission.html

  count         = var.target_is_lambda ? 1 : 0
  statement_id  = "AWSEvents_${var.rule.Name}_${var.rule_id}"
  action        = "lambda:InvokeFunction"
  function_name = split(":", var.target_arn)[6]
  principal     = "events.amazonaws.com"
  source_arn    = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${var.rule.EventBusName}/${var.rule.Name}"
}

resource "aws_cloudwatch_event_rule" "rule" {
  name           = var.rule.Name
  description    = var.rule.Description
  event_bus_name = var.rule.EventBusName
  event_pattern  = var.rule.EventPattern
  role_arn       = var.role_arn

  tags = {
    Environment = terraform.workspace
    Terraform   = "true"
  }
}

resource "aws_cloudwatch_event_target" "rule_target" {
  rule           = aws_cloudwatch_event_rule.rule.name
  event_bus_name = var.rule.EventBusName
  target_id      = var.rule_id
  arn            = var.target_arn
  role_arn       = var.role_arn
}


