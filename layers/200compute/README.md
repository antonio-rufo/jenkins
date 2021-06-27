## Summary

Terraform code to setup Compute layer.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\\_account\_id | (Required) AWS Account ID. | string | `n/a` | yes |
| region | (Required) Region where resources will be created. | string | `"ap-southeast-2"` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `"Development"` | no |
| role\_name | The IAM Role name. Conflicts with name\_prefix. Choose either. | string | `null` | no |
| name\_prefix | The IAM Role name prefix. Conflicts with name. Choose either. | string | `null` | no |
| assume\_role\_policy | Assume Role Policy. | string | `""` | no |
| force\_detach\_policies | Allow policy / policies to be forcibly detached. | bool | `false` | no |
| path | IAM Role path. | string | `"/"` | no |
| description | IAM Role description. | string | `"Managed by Terraform"` | no |
| policy\_arn | List of policy ARNs to attached to the role. | list(string) | `n/a` | yes |
| principal\_type | Principal type for trust identity. | string | `"Service"` | no |
| principal\_identifiers | Principal identifier for trust identity. | list(string) | `["ec2.amazonaws.com"]` | no |
| internal | Is the ALB internal? | bool | `false` | no |
| enable\_cross\_zone\_load\_balancing | Enable / Disable cross zone load balancing. | bool | `false` | no |
| enable\_deletion\_protection | Enable / Disable deletion protection for the ALB. | bool | `false` | no |
| svc\_port | Service port: The port on which targets receive traffic. | number | `8080` | no |
| target\_group\_protocol | The protocol to use to connect to the target. | string | `"HTTP"` | no |
| healthy\_threshold | ALB healthy count. | number | `2` | no |
| unhealthy\_threshold | ALB unhealthy count. | number | `10` | no |
| timeout | ALB timeout value. | number | `5` | no |
| interval | ALB health check interval. | number | `20` | no |
| success\_codes | Success Codes for the Target Group Health Checks. Default is 200 ( OK ). | string | `"200"` | no |
| target\_group\_path | Health check request path. | string | `"/"` | no |
| target\_group\_port | The port to use to connect with the target. | number | `8080` | no |
| http\_listener\_required | Enables / Disables creating HTTP listener. Listener auto redirects to HTTPS. | bool | `true` | no |
| listener1\_alb\_listener\_port | HTTP listener port. | number | `80` | no |
| listener1\_alb\_listener\_protocol | HTTP listener protocol. | string | `"HTTP"` | no |
| alb\_listener\_port | ALB listener port. | number | `"443"` | no |
| certificate\_arn | ARN of the SSL certificate to use. | string | `n/a` | yes |
| alb\_listener\_protocol | ALB listener protocol. | string | `"HTTPS"` | no |
| instance\_type | ec2 instance type. | string | `"t3a.medium"` | no |
| key\_name | ec2 key pair use. | string | `n/a` | yes |
| enable\_monitoring | AutoScaling - enables/disables detailed monitoring. | bool | `false` | no |
| custom\_userdata | Set custom userdata. | string | `""` | no |
| volume\_size | ec2 volume size. | number | `30` | no |
| volume\_type | ec2 volume type. | string | `"gp2"` | no |
| encrypted | Encryption of volumes. | bool | `true` | no |
| hostname\_prefix | Hostname prefix for the Jenkins server. | string | `"jenkins"` | no |
| domain\_name | Domain Name. | string | `n/a` | yes |
| supplementary\_user\_data | Supplementary shell script commands for adding to user data.Runs at the end of userdata. | string | `"#supplementary\_user\_data"` | no |
| autoscaling\_schedule\_create | Allows for disabling of scheduled actions on ASG. Enabled by default. | number | `1` | no |
| scale\_down\_cron | The time when the recurring scale down action start. Cron format. | string | `"0 0 * * SUN"` | no |
| scale\_up\_cron | The time when the recurring scale up action start.Cron format. | string | `"30 0 * * SUN"` | no |
| max\_size | AutoScaling Group max size. | number | `1` | no |
| min\_size | AutoScaling Group min size. | number | `1` | no |
| desired\_capacity | AutoScaling Group desired capacity. | number | `1` | no |
| health\_check\_grace\_period | AutoScaling health check grace period. | number | `180` | no |
| health\_check\_type | AutoScaling health check type. EC2 or ELB. | string | `"ELB"` | no |
| create\_dns\_record | Create friendly DNS CNAME. | bool | `true` | no |
| zone\_id | Route 53 zone id. | string | `null` | no |
| route53\_endpoint\_record | Route 53 endpoint name. Creates route53\_endpoint\_record. | string | `"jenkins"` | no |

## Outputs

| Name | Description |
|------|-------------|
| jenkins\_url | Jenkins URL. |
