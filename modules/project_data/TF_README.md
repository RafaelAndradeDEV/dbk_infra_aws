<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13.1 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_admin_group"></a> [account\_admin\_group](#output\_account\_admin\_group) | Unity Catalog admin group name |
| <a name="output_account_groups"></a> [account\_groups](#output\_account\_groups) | Account-level groups with workspaces scoping |
| <a name="output_account_service_principals"></a> [account\_service\_principals](#output\_account\_service\_principals) | Account-level service principals |
| <a name="output_account_users"></a> [account\_users](#output\_account\_users) | Account-level users |
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS region |
| <a name="output_backend_state_bucket_name"></a> [backend\_state\_bucket\_name](#output\_backend\_state\_bucket\_name) | S3 bucket name for Terraform remote state |
| <a name="output_cluster_relay_endpoint_service"></a> [cluster\_relay\_endpoint\_service](#output\_cluster\_relay\_endpoint\_service) | Cluster connectivity relay endpoint service from Databricks |
| <a name="output_databricks_account_id"></a> [databricks\_account\_id](#output\_databricks\_account\_id) | Databricks Account ID |
| <a name="output_default_catalog"></a> [default\_catalog](#output\_default\_catalog) | Default catalog |
| <a name="output_default_tags"></a> [default\_tags](#output\_default\_tags) | Default tags for resources |
| <a name="output_enable_backend_private_link"></a> [enable\_backend\_private\_link](#output\_enable\_backend\_private\_link) | Whether to enable Databricks back-end PrivateLink in the VPC module |
| <a name="output_metastore_config"></a> [metastore\_config](#output\_metastore\_config) | Metastore configuration |
| <a name="output_network_cidr_block"></a> [network\_cidr\_block](#output\_network\_cidr\_block) | VPC CIDR block |
| <a name="output_private_subnets_cidr"></a> [private\_subnets\_cidr](#output\_private\_subnets\_cidr) | Private subnets CIDR list |
| <a name="output_project_name"></a> [project\_name](#output\_project\_name) | Project name |
| <a name="output_public_subnets_cidr"></a> [public\_subnets\_cidr](#output\_public\_subnets\_cidr) | Public subnets CIDR list |
| <a name="output_service_direct_endpoint_service"></a> [service\_direct\_endpoint\_service](#output\_service\_direct\_endpoint\_service) | Service-direct endpoint service from Databricks (covers telemetry and direct service access) |
| <a name="output_storage_credential_configs"></a> [storage\_credential\_configs](#output\_storage\_credential\_configs) | Optional map of Unity Catalog storage credential configs (from project\_configs.yml) |
| <a name="output_workspace_account_groups"></a> [workspace\_account\_groups](#output\_workspace\_account\_groups) | Per-workspace list of group assignments derived from workspace\_configs.yml |
| <a name="output_workspace_endpoint_service"></a> [workspace\_endpoint\_service](#output\_workspace\_endpoint\_service) | Workspace endpoint endpoint service from Databricks |
| <a name="output_workspace_groups"></a> [workspace\_groups](#output\_workspace\_groups) | Databricks workspace groups |
| <a name="output_workspace_name"></a> [workspace\_name](#output\_workspace\_name) | Databricks workspace name |
| <a name="output_workspace_names"></a> [workspace\_names](#output\_workspace\_names) | List of workspace names |
| <a name="output_workspace_service_principals"></a> [workspace\_service\_principals](#output\_workspace\_service\_principals) | Databricks workspace service principals |
| <a name="output_workspace_users"></a> [workspace\_users](#output\_workspace\_users) | Databricks workspace users |
| <a name="output_workspaces"></a> [workspaces](#output\_workspaces) | Map of workspaces keyed by name |
<!-- END_TF_DOCS -->