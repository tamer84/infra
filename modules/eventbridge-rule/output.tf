output "rule_arn" {
  value = "arn:aws:events:${var.aws_region}:${data.aws_caller_identity.current.account_id}:rule/${var.rule.EventBusName}/${var.rule.Name}"
}