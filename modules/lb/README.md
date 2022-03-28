
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
