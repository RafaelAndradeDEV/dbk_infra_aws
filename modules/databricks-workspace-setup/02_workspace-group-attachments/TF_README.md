<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.90.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks.workspace"></a> [databricks.workspace](#provider\_databricks.workspace) | >= 1.90.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.13.1 |

## Resources

| Name | Type |
|------|------|
| [databricks_grants.catalog](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.external_location](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.schema](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_grants.storage_credential](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants) | resource |
| [databricks_permission_assignment.group_workspace](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permission_assignment) | resource |
| [databricks_permissions.cluster_usage](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.sql_warehouse_usage](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [time_sleep.wait_after_workspace_assignment](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_groups"></a> [account\_groups](#input\_account\_groups) | n/a | ```list(object({ group_name = string workspaces = list(string) workspace_permissions = optional(map(list(string))) catalog_privileges = optional(list(object({ catalog_name = string, privileges = list(string) }))) schema_privileges = optional(list(object({ catalog_name = string, schema_name = string, privileges = list(string) }))) external_location_privileges = optional(list(object({ external_location_name = string, privileges = list(string) }))) storage_credential_privileges = optional(list(object({ storage_credential_name = string, privileges = list(string) }))) cluster_privileges = optional(list(object({ cluster_name = string, privileges = list(string) }))) sql_warehouse_privileges = optional(list(object({ warehouse_name = string, privileges = list(string) }))) }))``` | n/a | yes |
| <a name="input_apply_catalog_grants"></a> [apply\_catalog\_grants](#input\_apply\_catalog\_grants) | n/a | `bool` | `true` | no |
| <a name="input_bound_storage_credential_names"></a> [bound\_storage\_credential\_names](#input\_bound\_storage\_credential\_names) | List of storage credential names that are bound to the workspace. | `list(string)` | `[]` | no |
| <a name="input_cluster_ids"></a> [cluster\_ids](#input\_cluster\_ids) | n/a | `map(string)` | n/a | yes |
| <a name="input_group_principal_ids"></a> [group\_principal\_ids](#input\_group\_principal\_ids) | n/a | `map(object({ id = string, display_name = string }))` | n/a | yes |
| <a name="input_sql_warehouse_ids"></a> [sql\_warehouse\_ids](#input\_sql\_warehouse\_ids) | n/a | `map(string)` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | n/a | `string` | n/a | yes |
<!-- END_TF_DOCS -->
