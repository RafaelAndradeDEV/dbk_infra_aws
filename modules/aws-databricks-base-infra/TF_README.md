<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=6.14.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.90.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.1 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.90.0 |
| <a name="provider_time"></a> [time](#provider\_time) | 0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.7.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.root_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [databricks_mws_networks.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_networks) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [time_sleep.wait_for_group_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | (Required) AWS region | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | (Required) CIDR block for the VPC that will be used to create the Databricks workspace | `string` | n/a | yes |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix for the resources deployed by this module | `string` | n/a | yes |
| <a name="input_private_subnets_cidr"></a> [private\_subnets\_cidr](#input\_private\_subnets\_cidr) | (Optional) Private subnets CIDR list. If not set, calculated from cidr\_block | `list(string)` | `null` | no |
| <a name="input_public_subnets_cidr"></a> [public\_subnets\_cidr](#input\_public\_subnets\_cidr) | (Optional) Public subnets CIDR list. If not set, calculated from cidr\_block | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) Map of tags to apply to all created resources | `map(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn) | AWS Cross account role arn |
| <a name="output_databricks_credentials_id"></a> [databricks\_credentials\_id](#output\_databricks\_credentials\_id) | Databricks MWS credentials ID |
| <a name="output_databricks_network_id"></a> [databricks\_network\_id](#output\_databricks\_network\_id) | Databricks MWS network ID |
| <a name="output_databricks_storage_configuration_id"></a> [databricks\_storage\_configuration\_id](#output\_databricks\_storage\_configuration\_id) | Databricks MWS storage configuration ID |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs for the private route tables associated with this VPC |
| <a name="output_root_bucket"></a> [root\_bucket](#output\_root\_bucket) | root bucket |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security group ID for DB Compliant VPC |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | private subnets for workspace creation |
| <a name="output_vpc_endpoint_ids"></a> [vpc\_endpoint\_ids](#output\_vpc\_endpoint\_ids) | Interface VPC endpoint IDs for Databricks PrivateLink (if enabled) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_main_route_table_id"></a> [vpc\_main\_route\_table\_id](#output\_vpc\_main\_route\_table\_id) | ID for the main route table associated with this VPC |
<!-- END_TF_DOCS -->
