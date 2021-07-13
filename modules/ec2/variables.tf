variable "server_url" {
  type = string
  default = ""
}

variable "template_file" {
  type = string
  default = ""
}

variable "server_name" {
  type = string
}

variable "amount" {
  type = number
}

variable "availability_zone" {
  type = string
}

variable "storage_size" {
  type = number
  default = 0
}

variable "storage_type" {
  type = string
  default = ""
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "instance_profile" {
  type = string
}

variable "zone_id" {
  type = string
  default = ""
}

variable "local_zone_id" {
  type = string
  default = ""
}

variable "notification_actions" {
  type = list(string)
  default = []
}

variable "storage_path" {
  type = string
  default = ""
}

variable "generate_certificate" {
  type = bool
}

variable "create_alarms" {
  type = bool
}

variable "create_dns"{
  type = bool
}

variable "create_local_dns"{
  type = bool
}

variable "local_output" {
  type = bool
  default = false
}

variable "create_ebs" {
  type = bool
}

variable "with_public_ip"{
  type = bool
}

variable "template_vars" {
  type = map(string)
  description = "Allows for variables to be passed as a json object and used in the template file, then the variables can be called in the template file as jsondecode(additional_vars).name_of_the_variable"
  default = {}
}
