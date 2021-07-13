variable "event_rule_name" {
  type        = string
  description = "Name of the event rule"
}

variable "rate" {
  type        = string
  default     = "rate(1 minute)"
  description = "Rate at which the rule is triggered"
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function to be triggered"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function to be triggered"
}
