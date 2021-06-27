## Summary

Terraform code to setup VPC layer.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) AWS Account ID. | string | n/a | yes |
| region | (Required) Region where resources will be created. | string | `"ap-southeast-2"` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `"Development"` | no |

## Outputs

| Name | Description |
|------|-------------|
| public\_subnets | A list of private subnets inside the VPC. |
| private\_subnets | A list of public subnets inside the VPC. |
