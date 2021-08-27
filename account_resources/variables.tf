variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "hosted_zone" {
  default = "mbocdp.mercedes-benz.io"
}

variable "hosted_zone_com" {
  default = "mbocdp.mercedes-benz.com"
}

variable "infra_pipeline_envs" {
  default = ["dev", "test", "int", "prod"]
}

variable "session_manager_log_group" {
  type    = string
  default = "/aws/ssm/session_manager"
}


# Keeping this as it is useful for the future
# Don#t have to go digging
variable "dag_dns_server" {
  type    = string
  default = "53.18.127.10"
}

variable "subnet_count" {
  type    = number
  default = 2
}
