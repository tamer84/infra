## Inputs

| Name | Description | Type | Default | Required | Example |
|------|-------------|------|---------|:--------:|:--------:|
| aws\_region | n/a | `string` | `"eu-central-1"` | no | |
| cluster\_name | Name of the ECS cluster | `string` | n/a | yes | |
| container\_definitions | n/a | `map(string)` | n/a | yes |
| default\_ecs\_service\_name | Name of the default application\_entry\_container | `string` | n/a | yes |
| dns\_namespace\_id | ID of the Service Discovery namespace | `string` | n/a | yes |
| ecs\_services | List containing service definitions to be created | <pre>map(object({ // Expects key to be application_entry_container name<br>    desired_count = number<br>    target_group = object({<br>      priority = number<br>      application_port = number<br>      path = string<br>      action = string<br>      health_endpoint = string<br>      protocol = string<br>    })<br>    task_role = string<br>    cpu = number<br>    memory = number<br>  }))</pre> | n/a | yes |
| fargate\_security\_groups | IDs of the security group(s) for the Fargate service | `list(string)` | n/a | yes |
| is\_publicly\_accessible | Whether the resource needs a route53 registration | `bool` | n/a | yes |
| lb\_listeners | List of maps with definition of listeners. For TLS listeners, required params are port, protocol and certificate. For TCP listeners, required params are port and protocol | `map(any)` | `{}` | no |
| lb\_security\_groups | IDs of the security group(s) for the load balancer (Only required for application level lb) | `list(string)` | `[]` | no |
| lb\_type | Either network or application level load balancer | `string` | `"network"` | no |
| private\_subnets | IDs of the private subnets | `list(string)` | n/a | yes |
| public\_subnets | IDs of the public subnets (only needed if is\_publicly\_accessible is true) | `list(string)` | `[]` | no |
| vpc\_id | ID of the VPC | `string` | n/a | yes |
| zone\_id | ARN of the DNS Zone | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ecs\_cluster | ECS Cluster Resource |
| ecs\_service | ECS services' resource|
| route53\_record | Target group resources attached to the load balancer |

## Example (MVI)
```hcl-terraform
module "core-service" {
  source = "git::ssh://git@git.daimler.com/vpp/vpp-infra.git//modules/fargate?ref=develop"

  cluster_name             = "mvi"
  dns_namespace_id         = data.terraform_remote_state.environment_resources.outputs.private-dns-namespace.id
  fargate_security_groups  = [data.terraform_remote_state.environment_resources.outputs.group_internal_access.id]
  private_subnets          = data.terraform_remote_state.environment_resources.outputs.private-subnet.*.id
  lb_listeners             = local.alb_listeners
  lb_type                  = local.lb_type
  vpc_id                   = data.terraform_remote_state.environment_resources.outputs.vpc.id
  ecs_services             = local.ecs_services
  container_definitions    = local.container_definitions
  is_publicly_accessible   = false
  zone_id                  = data.terraform_remote_state.account_resources.outputs.dns.zone_id
  default_ecs_service_name = "mvi-core-plus" //This should match with a key on the local.ecs_services
}

locals {
    ecs_services = {
        "mvi-core-plus" = {
          "desired_count" : 1, // nr desired service instances (auto scaling)
          "target_group" : {  // lb target group
            "priority" : 1, 
            "action" : "forward", 
            "path" : "/*"  // this is only required for application level load balancers, 
                           //for network load balancers initialize this with empty string
                           //lb's path from which the lb redirects to the service
                           // eg. "/config/*" will make the loadbalancer redirect all requests to /config path into the service 
            "application_port" : 12345, // exposed port in use by the container's application
            "health_endpoint" : "/management/health", // for the service
            "protocol" : "HTTP"  // Load balancer's protocol (network lb uses "TCP" protocol)
          }
          "task_role" : "", // role/permissions assigned (ARN)
          "cpu" : 4096, // cpu of the service
          "memory" : 10240 // memory of the service
        } 
        // To have multiple services in this cluster 
        //Add another key with a value (object) with similar structure as this one
    }

    lb_type = "application" // application for application loadbalancer and network for network lb

    alb_listeners = {
        "http" = {
          "protocol" = "HTTP", // Protocol to which the load balance listens
          "port"     = "80" // Port on which the load balance listens
        }
    }

    container_definitions = {
        "mvi-core-plus" : module.merged.container_definitions  // key should match ecs' service name
    }
}
```