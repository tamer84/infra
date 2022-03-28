# this is the default ami of the bastion ec2 instance is based on
variable "default_ami" {
  type    = string
  default = "ami-0cc0a36f626a4fdf5"
}

variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "hosted_zone" {
  default = "tamer84.com"
}


variable "local_output" {
  type    = bool
  default = true
}

variable "vpcs_cidr_prefix" {
  type    = string
  default = "10.31."
}

variable "vpcs_cidr_suffix" {
  type    = string
  default = ".0/18"
}

variable "subnets_cidr_suffix" {
  type    = string
  default = ".0/20"
}


variable "subnet_count" {
  type    = number
  default = 2
}

