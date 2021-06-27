## Summary

Terraform code to setup VPC layer.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| aws\_account\_id | (Required) AWS Account ID. | string | n/a | yes |
| region | (Required) Region where resources will be created. | string | `ap-southeast-1` | no |
| environment | (Optional) The name of the environment, e.g. Production, Development, etc. | string | `"Development"` | no |
| deletion\_window\_in\_days | Number of days before permanent removal. | number | `"30"` | no |
| enable\_key\_rotation | KMS key rotation. | bool | `true` | no |
| efs\_encrypted | Encrypt the EFS share. | bool | `true` | no |
| performance\_mode | EFS performance mode.https://docs.aws.amazon.com/efs/latest/ug/performance.html. | string | `"generalPurpose"` | no |

## Outputs

| Name | Description |
|------|-------------|
| efs\_dns\_name | DNS name of the EFS share. |
