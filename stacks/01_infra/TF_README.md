<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.14.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.90.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_base"></a> [aws\_base](#module\_aws\_base) | ../../modules/aws-databricks-base-infra | n/a |
| <a name="module_project_data"></a> [project\_data](#module\_project\_data) | ../../modules/project_data | n/a |

## Resources

| Name | Type |
|------|------|
| [terraform_data.validate_backend_privatelink_service_region](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id) | (Required) Databricks Client ID | `string` | n/a | yes |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret) | (Required) Databricks Client Secret | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources | `map(string)` | ```{ "Project": "Dbk-Project" }``` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_extra_security_group"></a> [aws\_extra\_security\_group](#output\_aws\_extra\_security\_group) | AWS extra security group ID |
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn) | Cross account role ARN |
| <a name="output_databricks_credentials_id"></a> [databricks\_credentials\_id](#output\_databricks\_credentials\_id) | Databricks MWS credentials ID |
| <a name="output_databricks_storage_configuration_id"></a> [databricks\_storage\_configuration\_id](#output\_databricks\_storage\_configuration\_id) | Databricks MWS storage configuration ID |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Private subnets for the workspace |
| <a name="output_root_bucket"></a> [root\_bucket](#output\_root\_bucket) | Root storage bucket for the workspace |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security group IDs for the workspace |
| <a name="output_storage_buckets"></a> [storage\_buckets](#output\_storage\_buckets) | Per-storage-credential bucket details (for use by later stacks) |
| <a name="output_storage_configuration_role_arn"></a> [storage\_configuration\_role\_arn](#output\_storage\_configuration\_role\_arn) | IAM role ARN for storage configuration |
| <a name="output_storage_credential_configs"></a> [storage\_credential\_configs](#output\_storage\_credential\_configs) | Pass-through: storage credential configs (for use by later stacks) |
| <a name="output_storage_data_access_role_arns"></a> [storage\_data\_access\_role\_arns](#output\_storage\_data\_access\_role\_arns) | Map of IAM role ARNs for UC storage credentials (for use by later stacks) |
| <a name="output_storage_data_access_role_names"></a> [storage\_data\_access\_role\_names](#output\_storage\_data\_access\_role\_names) | Map of IAM role names for UC storage credentials (for use by later stacks) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->