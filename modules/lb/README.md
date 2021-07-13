
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| default\_service\_name | Ecs service name for the default load balance forwarding | `string` | n/a | yes | 
| is\_publicly\_accessible | Whether the resource needs a route53 registration | `bool` | n/a | yes |
| lb\_listeners | List of maps with definition of listeners. For TLS listeners, required params are port, protocol and certificate. For TCP listeners, required params are port and protocol | `map(any)` | `{}` | no |
| lb\_name | Name of the application (e.g. dashboard) | `string` | n/a | yes |
| lb\_security\_groups | n/a | `list(string)` | `[]` | no |
| lb\_type | Specify application or network type loadbalance | `string` | `"network"` | no |
| private\_subnets | IDs of the private subnets | `list(string)` | n/a | yes |
| public\_subnets | IDs of the public subnets (only needed if is\_publicly\_accessible is true) | `list(string)` | `[]` | no |
| target\_groups | Target group map/list | <pre>map(object({<br>          priority         = number<br>          application_port = number<br>          path             = string<br>          action           = string<br>          health_endpoint  = string<br>          protocol         = string<br>  }))</pre> | `{}` | no |
| vpc\_id | ID of the VPC | `string` | n/a | yes |
| zone\_id | ARN of the DNS Zone (needed when the lb is publicly accessible) | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| aws\_lb | Load balance resource |
| aws\_lb\_listener | Load balance listener |
| route53\_record | DNS Record from Route53 |
| target\_groups | Target group resources attached to the load balancer |


## Example
```hcl-terraform
module "lb" {
  source = "git::ssh://git@git.daimler.com/vpp/vpp-infra.git//modules/lb?ref=develop"

  lb_security_groups     = [data.terraform_remote_state.environment_resources.outputs.group_internal_access.id]
  is_publicly_accessible = false
  lb_type                = local.lb_type
  lb_name                = local.lb_name
  private_subnets        = data.terraform_remote_state.environment_resources.outputs.private-subnet.*.id
  public_subnets         = data.terraform_remote_state.environment_resources.outputs.public-subnet.*.id
  vpc_id                 = data.terraform_remote_state.environment_resources.outputs.vpc.id
  lb_listeners           = local.alb_listeners
  target_groups          = local.target_groups
  default_service_name   = "service_name"
  zone_id                = data.terraform_remote_state.account_resources.outputs.dns.zone_id
}


locals {
    target_groups = {
        "mvi-core-plus" = {  // Key is base name of the target group
            "priority" : 1, //target group rule priority
            "action" : "forward", 
            "path" : "/*"  // this is only required for application level load balancers, 
                           //for network load balancers initialize this with empty string
                           //lb's path from which the lb redirects to the service
                           // eg. "/config/*" will make the loadbalancer redirect all requests to /config path into the service 
            "application_port" : 12345, // exposed port in use by the container's application
            "health_endpoint" : "/management/health", // for the service
            "protocol" : "HTTP"  // Load balancer's protocol (network lb uses "TCP" protocol)
          }
        // To have multiple target groups 
        //Add another key with a value (object) with similar structure as this one
    }

    lb_type = "application" // "application" for application loadbalancer and "network" for network lb

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