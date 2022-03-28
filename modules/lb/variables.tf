variable "lb_name" {
  description = "Name of the application (e.g. dashboard)"
  type        = string
}

variable "is_publicly_accessible" {
  description = "Whether the resource needs a route53 registration"
  type        = bool
}


variable "public_subnets" {
  description = "IDs of the public subnets (only needed if is_publicly_accessible is true)"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}


variable "lb_type" {
  description = "Specify application or network type loadbalance"
  type        = string
  default     = "network"
}

variable "lb_listeners" {
  description = "List of maps with definition of listeners. For TLS listeners, required params are port, protocol and certificate. For TCP listeners, required params are port and protocol"
  type        = map(any)
  default     = {}
}

variable "lb_security_groups" {
  description = ""
  type        = list(string)
  default     = []
}

variable "target_groups" {
  description = "Target group map/list"
  type        = map(object({
          priority         = number
          application_port = number
          path             = string
          action           = string
          health_endpoint  = string
          protocol         = string
  }))
  default = {}
}

variable "default_service_name" {
  description = "Ecs service name for the default load balance forwarding"
  type        = string
}

variable "zone_id" {
  description = "ARN of the DNS Zone (needed when the lb is publicly accessible)"
  type        = string
  default     = ""
}