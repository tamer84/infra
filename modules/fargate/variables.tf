variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1"
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

variable "fargate_security_groups" {
  description = "IDs of the security group(s) for the Fargate service"
  type        = list(string)
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "dns_namespace_id" {
  description = "ID of the Service Discovery namespace"
  type        = string
}

variable "is_publicly_accessible" {
  description = "Whether the resource needs a route53 registration"
  type        = bool
}

variable "lb_listeners" {
  description = "List of maps with definition of listeners. For TLS listeners, required params are port, protocol and certificate. For TCP listeners, required params are port and protocol"
  type        = map(any)
  default     = {}
}

variable "zone_id" {
  description = "ARN of the DNS Zone"
  type        = string
}

variable "ecs_services" {
  description = "List containing service definitions to be created"
  type        = map(object({ // Expects key to be application_entry_container name
    desired_count = number
    target_group = object({
      priority = number
      application_port = number
      path = string
      action = string
      health_endpoint = string
      protocol = string
    })
    task_role = string
    cpu = number
    memory = number
  }))
}

variable "container_definitions" {
  type = map(string)
}

variable "default_ecs_service_name" {
  description = "Name of the default application_entry_container"
  type = string
}

variable "lb_type" {
  description = "Either network or application level load balancer"
  type        = string
  default     = "network"
}


variable "lb_security_groups" {
  description = "IDs of the security group(s) for the load balancer (Only required for application level lb)"
  type        = list(string)
  default     = []
}