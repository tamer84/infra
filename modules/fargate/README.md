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
