<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.14.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.90.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | >= 1.90.0 |
| <a name="provider_databricks.workspace"></a> [databricks.workspace](#provider\_databricks.workspace) | >= 1.90.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_databricks_workspace_configuration"></a> [databricks\_workspace\_configuration](#module\_databricks\_workspace\_configuration) | ./01_databricks-workspace-objects | n/a |
| <a name="module_workspace_group_attachments"></a> [workspace\_group\_attachments](#module\_workspace\_group\_attachments) | ./02_workspace-group-attachments | n/a |

## Resources

| Name | Type |
|------|------|
| [databricks_budget.ai_gateway](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/budget) | resource |
| [databricks_budget.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/budget) | resource |
| [databricks_external_location.external_locations](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location) | resource |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment) | resource |
| [databricks_workspace_binding.storage_credentials](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_binding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_groups"></a> [account\_groups](#input\_account\_groups) | n/a | `any` | n/a | yes |
| <a name="input_admin_group_principal_id"></a> [admin\_group\_principal\_id](#input\_admin\_group\_principal\_id) | n/a | `string` | n/a | yes |
| <a name="input_ai_gateway_budget_amount"></a> [ai\_gateway\_budget\_amount](#input\_ai\_gateway\_budget\_amount) | Monthly budget cap in USD for AI Gateway spending | `number` | `0` | no |
| <a name="input_ai_gateway_budget_notification_emails"></a> [ai\_gateway\_budget\_notification\_emails](#input\_ai\_gateway\_budget\_notification\_emails) | List of emails to receive AI Gateway budget alerts | `list(string)` | `[]` | no |
| <a name="input_all_purpose_clusters"></a> [all\_purpose\_clusters](#input\_all\_purpose\_clusters) | List of all-purpose clusters to create. All fields except 'name' are optional with sensible defaults. | ```list(object({ name = string min_workers = optional(number) max_workers = optional(number) num_workers = optional(number) autotermination_minutes = optional(number) spark_version = optional(string) node_type_id = optional(string) driver_node_type_id = optional(string) runtime_engine = optional(string) data_security_mode = optional(string) single_user_name = optional(string) kind = optional(string) is_pinned = optional(bool) spark_conf = optional(map(string)) spark_env_vars = optional(map(string)) custom_tags = optional(map(string)) init_scripts = optional(list(object({ workspace = optional(object({ destination = string })) volumes = optional(object({ destination = string })) dbfs = optional(object({ destination = string })) s3 = optional(object({ destination = string })) gcs = optional(object({ destination = string })) abfss = optional(object({ destination = string })) }))) aws_attributes = optional(object({ availability = optional(string) zone_id = optional(string) first_on_demand = optional(number) spot_bid_price_percent = optional(number) ebs_volume_type = optional(string) ebs_volume_count = optional(number) ebs_volume_size = optional(number) ebs_volume_iops = optional(number) ebs_volume_throughput = optional(number) })) cluster_log_conf = optional(object({ dbfs = optional(object({ destination = string })) s3 = optional(object({ destination = string region = optional(string) endpoint = optional(string) enable_encryption = optional(bool) encryption_type = optional(string) kms_key = optional(string) canned_acl = optional(string) })) })) library = optional(list(object({ jar = optional(string) egg = optional(string) whl = optional(string) pypi = optional(object({ package = string, repo = optional(string) })) maven = optional(object({ coordinates = string, repo = optional(string), exclusions = optional(list(string)) })) cran = optional(object({ package = string, repo = optional(string) })) }))) }))``` | `[]` | no |
| <a name="input_budget_amount"></a> [budget\_amount](#input\_budget\_amount) | Budget Value in USD | `number` | `0` | no |
| <a name="input_budget_notification_emails"></a> [budget\_notification\_emails](#input\_budget\_notification\_emails) | List of emails to receive cost alerts | `list(string)` | ```[ "budget-alerts@example.com", "budget-alerts@example.com", "budget-alerts@example.com" ]``` | no |
| <a name="input_budget_tag_filter"></a> [budget\_tag\_filter](#input\_budget\_tag\_filter) | n/a | `map(list(string))` | `{}` | no |
| <a name="input_catalogs"></a> [catalogs](#input\_catalogs) | n/a | ```list(object({ name = string isolation_mode = string purpose = string storage_root = optional(string) }))``` | `[]` | no |
| <a name="input_cluster_tags"></a> [cluster\_tags](#input\_cluster\_tags) | Tags to apply to the cluster | `map(string)` | `{}` | no |
| <a name="input_default_sql_wh_name"></a> [default\_sql\_wh\_name](#input\_default\_sql\_wh\_name) | n/a | `string` | n/a | yes |
| <a name="input_dev_schema_catalog_name"></a> [dev\_schema\_catalog\_name](#input\_dev\_schema\_catalog\_name) | n/a | `string` | n/a | yes |
| <a name="input_external_locations"></a> [external\_locations](#input\_external\_locations) | Optional list of Unity Catalog external locations to create in this workspace/metastore. | ```list(object({ name = string url = string credential_name = string comment = optional(string) }))``` | `[]` | no |
| <a name="input_federated_catalogs"></a> [federated\_catalogs](#input\_federated\_catalogs) | List of federated catalog definitions. Supports any Databricks connection type. Non-sensitive connection options go in 'options'; secrets fetched from AWS Secrets Manager go in 'secrets'. | ```list(object({ name = string connection_type = string comment = optional(string) read_only = optional(bool) options = map(string) secrets = optional(list(object({ option_key = string secret_arn = string secret_json_key = string })), []) catalog_options = optional(map(string), {}) }))``` | `[]` | no |
| <a name="input_metastore_id"></a> [metastore\_id](#input\_metastore\_id) | n/a | `string` | n/a | yes |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | n/a | ```list(object({ name = string catalogs = list(string) }))``` | `[]` | no |
| <a name="input_sql_endpoint_tags"></a> [sql\_endpoint\_tags](#input\_sql\_endpoint\_tags) | Tags to apply to the SQL warehouse | `map(string)` | `{}` | no |
| <a name="input_sql_warehouses"></a> [sql\_warehouses](#input\_sql\_warehouses) | List of SQL warehouses to create | ```list(object({ name = string cluster_size = string max_num_clusters = number min_num_clusters = optional(number) warehouse_type = optional(string) auto_stop_mins = optional(number) spot_instance_policy = optional(string) enable_photon = optional(bool) enable_serverless_compute = optional(bool) channel = optional(string) }))``` | `[]` | no |
| <a name="input_storage_credential_names"></a> [storage\_credential\_names](#input\_storage\_credential\_names) | Optional list of Unity Catalog storage credential names to bind to this workspace. If empty, no bindings are created. | `list(string)` | `[]` | no |
| <a name="input_users"></a> [users](#input\_users) | n/a | `list(object({ name = string, email = string }))` | n/a | yes |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id) | n/a | `string` | n/a | yes |
| <a name="input_workspace_name"></a> [workspace\_name](#input\_workspace\_name) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
<!-- END_TF_DOCS -->
