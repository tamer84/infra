variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "hosted_zone" {
  default = "tango.tamerhusnu.com"
}

variable "infra_pipeline_envs" {
  default = ["dev", "test", "int", "prod"]
}

variable "session_manager_log_group" {
  type    = string
  default = "/aws/ssm/session_manager"
}

variable "subnet_count" {
  type    = number
  default = 2
}
