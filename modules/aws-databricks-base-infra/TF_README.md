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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >=6.14.1 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >=1.90.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.13.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_storage_buckets"></a> [storage\_buckets](#module\_storage\_buckets) | ./storage_bucket | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 5.7.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | terraform-aws-modules/vpc/aws//modules/vpc-endpoints | 5.7.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.cross_account_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.storage_data_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.unity_catalog_main_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.extra_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.file_events_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.storage_data_access_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.uc_combined_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.root_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.root_storage_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.root_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.databricks_scc_vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.databricks_workspace_vpce](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.extra_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [databricks_mws_credentials.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_credentials) | resource |
| [databricks_mws_private_access_settings.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_private_access_settings) | resource |
| [databricks_mws_storage_configurations.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_storage_configurations) | resource |
| [databricks_mws_vpc_endpoint.relay](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [databricks_mws_vpc_endpoint.workspace](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mws_vpc_endpoint) | resource |
| [terraform_data.update_trust_policy](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.validate_backend_privatelink](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.wait_for_group_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | (Required) AWS region | `string` | n/a | yes |
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | (Required) CIDR block for the VPC that will be used to create the Databricks workspace | `string` | n/a | yes |
| <a name="input_cluster_relay_endpoint_service"></a> [cluster\_relay\_endpoint\_service](#input\_cluster\_relay\_endpoint\_service) | (Optional) Databricks cluster connectivity relay VPC endpoint service name (required if enable\_backend\_private\_link = true) | `string` | `null` | no |
| <a name="input_databricks_account_id"></a> [databricks\_account\_id](#input\_databricks\_account\_id) | (Required) Databricks Account ID | `string` | n/a | yes |
| <a name="input_databricks_dataplane_security_group_id"></a> [databricks\_dataplane\_security\_group\_id](#input\_databricks\_dataplane\_security\_group\_id) | (Optional) Security group ID used by Databricks dataplane. If null, we fall back to the first ID in local.effective\_security\_group\_ids. | `string` | `null` | no |
| <a name="input_databricks_uc_master_role_arn"></a> [databricks\_uc\_master\_role\_arn](#input\_databricks\_uc\_master\_role\_arn) | (Optional) Databricks UC master role ARN (override for GovCloud) | `string` | `"arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"` | no |
| <a name="input_enable_backend_private_link"></a> [enable\_backend\_private\_link](#input\_enable\_backend\_private\_link) | Enable Databricks back-end PrivateLink (creates interface endpoints + Databricks endpoint registrations). Reuses the VPC/subnets from vpc.tf. | `bool` | `false` | no |
| <a name="input_extra_pass_role_arns"></a> [extra\_pass\_role\_arns](#input\_extra\_pass\_role\_arns) | (Optional) IAM role ARNs the cross-account role may pass (iam:PassRole), e.g. a CI agent role used for custom container images. Empty disables the extra policy. | `list(string)` | `[]` | no |
| <a name="input_metastore_bucket_name"></a> [metastore\_bucket\_name](#input\_metastore\_bucket\_name) | (Required) Metastore bucket name | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix for the resources deployed by this module | `string` | n/a | yes |
| <a name="input_private_access_public_access_enabled"></a> [private\_access\_public\_access\_enabled](#input\_private\_access\_public\_access\_enabled) | When using Private Access Settings, allow public access to the workspace URL. Set to false only if you have front-end PrivateLink/VPN for users and Terraform. | `bool` | `true` | no |
| <a name="input_private_subnet_prefix_length"></a> [private\_subnet\_prefix\_length](#input\_private\_subnet\_prefix\_length) | (Required) Prefix length for subnets (/17.. /26). Must be >= VPC prefix. | `number` | `24` | no |
| <a name="input_reuse_metastore"></a> [reuse\_metastore](#input\_reuse\_metastore) | (Required) Reuse metastore bucket. Skips creating root bucket if true | `bool` | `false` | no |
| <a name="input_service_direct_endpoint_service"></a> [service\_direct\_endpoint\_service](#input\_service\_direct\_endpoint\_service) | (Optional) Databricks service-direct VPC endpoint service name (optional, covers telemetry and direct service access) | `string` | `null` | no |
| <a name="input_storage_credential_configs"></a> [storage\_credential\_configs](#input\_storage\_credential\_configs) | (Optional) Map of Unity Catalog storage credential configs.  Each item creates one `databricks_storage_credential` and a dedicated IAM role scoped to that bucket/prefix. If `create_bucket` is true, the S3 bucket is created via the `./storage_bucket` submodule. `prefix` scopes object access to that key prefix inside the bucket (default: "*"). | ```map(object({ name = string bucket_name = string create_bucket = optional(bool, false) prefix = optional(string, "*") }))``` | `{}` | no |
| <a name="input_subnet_block_to_create"></a> [subnet\_block\_to\_create](#input\_subnet\_block\_to\_create) | (Required) Number of private subnet blocks to create from cidr\_block | `number` | `6` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Required) Map of tags to apply to all created resources | `map(string)` | n/a | yes |
| <a name="input_workspace_endpoint_service"></a> [workspace\_endpoint\_service](#input\_workspace\_endpoint\_service) | (Optional) Databricks workspace (REST API) VPC endpoint service name (required if enable\_backend\_private\_link = true) | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_extra_security_group"></a> [aws\_extra\_security\_group](#output\_aws\_extra\_security\_group) | AWS extra security group ID |
| <a name="output_cross_account_role_arn"></a> [cross\_account\_role\_arn](#output\_cross\_account\_role\_arn) | AWS Cross account role arn |
| <a name="output_databricks_credentials_id"></a> [databricks\_credentials\_id](#output\_databricks\_credentials\_id) | Databricks MWS credentials ID |
| <a name="output_databricks_storage_configuration_id"></a> [databricks\_storage\_configuration\_id](#output\_databricks\_storage\_configuration\_id) | Databricks MWS storage configuration ID |
| <a name="output_databricks_vpc_endpoint_ids"></a> [databricks\_vpc\_endpoint\_ids](#output\_databricks\_vpc\_endpoint\_ids) | Databricks MWS VPC endpoint IDs for back-end PrivateLink (null when disabled) |
| <a name="output_private_access_settings_id"></a> [private\_access\_settings\_id](#output\_private\_access\_settings\_id) | Databricks Private Access Settings ID required for PrivateLink workspaces (null when disabled) |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | IDs for the private route tables associated with this VPC |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | private subnets for workspace creation |
| <a name="output_root_bucket"></a> [root\_bucket](#output\_root\_bucket) | root bucket |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Security group ID for DB Compliant VPC |
| <a name="output_storage_buckets"></a> [storage\_buckets](#output\_storage\_buckets) | Per-storage-credential bucket details (created or referenced) keyed by config key |
| <a name="output_storage_configuration_role_arn"></a> [storage\_configuration\_role\_arn](#output\_storage\_configuration\_role\_arn) | IAM role ARN for storage configuration |
| <a name="output_storage_credential_configs"></a> [storage\_credential\_configs](#output\_storage\_credential\_configs) | Pass-through: storage credential configs used to create AWS-side resources in this module |
| <a name="output_storage_data_access_role_arns"></a> [storage\_data\_access\_role\_arns](#output\_storage\_data\_access\_role\_arns) | Map of IAM role ARNs for UC storage credentials (keyed by storage\_credential\_configs key) |
| <a name="output_storage_data_access_role_names"></a> [storage\_data\_access\_role\_names](#output\_storage\_data\_access\_role\_names) | Map of IAM role names for UC storage credentials (keyed by storage\_credential\_configs key) |
| <a name="output_vpc_endpoint_ids"></a> [vpc\_endpoint\_ids](#output\_vpc\_endpoint\_ids) | Interface VPC endpoint IDs for Databricks PrivateLink (if enabled) |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_main_route_table_id"></a> [vpc\_main\_route\_table\_id](#output\_vpc\_main\_route\_table\_id) | ID for the main route table associated with this VPC |
<!-- END_TF_DOCS -->