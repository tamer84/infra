variable "rule" {
  description = "Event brigdge rule"
  type = object({
    Name         = string
    EventPattern = string
    State        = string
    Description  = string
    EventBusName = string
  })
}

variable "rule_id" {
  type = string
}

variable "target_arn" {
  description = "Resource ARN to be the rule target"
  type        = string
}

variable "role_arn" {
  description = "Role to use to call the target (not needed for lambda triggers)"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS Region on which the rule is created"
  type        = string
  default     = "eu-central-1"
}

variable "target_is_lambda" {
  description = "Specifies if the rule target is a Lambda so the permission is created"
  type        = bool
  default     = true
}