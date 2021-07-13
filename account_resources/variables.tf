variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "hosted_zone" {
  default = "vpp.mercedes-benz.io"
}

variable "hosted_zone_com" {
  default = "vpp.mercedes-benz.com"
}

variable "slack_url" {
  type    = string
  default = "https://hooks.slack.com/services/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"
}

variable "infra_pipeline_envs" {
  default = ["dev", "test", "int", "prod"]
}

variable "session_manager_log_group" {
  type    = string
  default = "/aws/ssm/session_manager"
}

#TODO: Add this to Secrets store
variable "psk" {
  type    = string
  default = "4tBeQ8914Qw3s1ZP7Adt99YZSjd54o12P4991v219o3IO41j2VD5tGf575"
}

variable "dag_dns_server" {
  type    = string
  default = "53.18.127.10"
}

variable "subnet_count" {
  type    = number
  default = 2
}

variable "route_table_cidr_blocks" {
  type    = list(string)
  default = ["10.0.0.0/8", "53.0.0.0/8"]
}