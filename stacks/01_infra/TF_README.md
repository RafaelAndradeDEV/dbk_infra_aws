<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.14.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.90.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aws_base"></a> [aws\_base](#module\_aws\_base) | ../../modules/aws-databricks-base-infra | n/a |
| <a name="module_project_data"></a> [project\_data](#module\_project\_data) | ../../modules/project_data | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id) | (Required) Databricks Client ID | `string` | n/a | yes |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret) | (Required) Databricks Client Secret | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to created resources | `map(string)` | ```{ "Project": "indimesh" }``` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn) | Cross account role ARN |
| <a name="output_databricks_credentials_id"></a> [databricks\_credentials\_id](#output\_databricks\_credentials\_id) | Databricks MWS credentials ID |
| <a name="output_databricks_network_id"></a> [databricks\_network\_id](#output\_databricks\_network\_id) | Databricks MWS network ID |
| <a name="output_databricks_storage_configuration_id"></a> [databricks\_storage\_configuration\_id](#output\_databricks\_storage\_configuration\_id) | Databricks MWS storage configuration ID |
| <a name="output_root_bucket"></a> [root\_bucket](#output\_root\_bucket) | Root storage bucket for the workspace |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security group IDs for the workspace |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Private subnets for the workspace |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
<!-- END_TF_DOCS -->
