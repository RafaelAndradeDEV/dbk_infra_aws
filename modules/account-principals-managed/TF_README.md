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
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | >= 1.90.0 |

## Resources

| Name | Type |
|------|------|
| [databricks_access_control_rule_set.group_permissions](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/access_control_rule_set) | resource |
| [databricks_access_control_rule_set.sp_permissions](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/access_control_rule_set) | resource |
| [databricks_group.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group) | resource |
| [databricks_group_member.sp_membership](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_group_member.user_membership](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_service_principal.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal) | resource |
| [databricks_user.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | Databricks account ID, used to construct access control rule set names for service principals. | `string` | n/a | yes |
| <a name="input_groups"></a> [groups](#input\_groups) | n/a | ```list(object({ group_name = string skip_create = optional(bool) workspaces = optional(list(string)) workspace_permissions = optional(map(list(string))) catalog_privileges = optional(list(object({ catalog_name = string, privileges = list(string) }))) cluster_privileges = optional(list(object({ cluster_name = string, privileges = list(string) }))) permissions = optional(list(object({ role = list(string) principals = list(object({ type = string, name = string })) }))) }))``` | `[]` | no |
| <a name="input_service_principals"></a> [service\_principals](#input\_service\_principals) | n/a | ```list(object({ name = string display_name = optional(string) groups = optional(list(string)) permissions = optional(list(object({ role = list(string) principals = list(object({ type = string, name = string })) }))) }))``` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | n/a | ```list(object({ name = optional(string) email = string allow_cluster_create = optional(bool) groups = optional(list(string)) }))``` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_groups_map"></a> [groups\_map](#output\_groups\_map) | n/a |
| <a name="output_membership_debug"></a> [membership\_debug](#output\_membership\_debug) | Compact debug counters for account-level group membership reconciliation |
<!-- END_TF_DOCS -->
