<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.14.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.90.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.13.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.102.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_project_data"></a> [project\_data](#module\_project\_data) | ../../modules/project_data | n/a |
| <a name="module_sandbox_workspace_creation"></a> [sandbox\_workspace\_creation](#module\_sandbox\_workspace\_creation) | ../../modules/databricks-workspace-creation | n/a |
| <a name="module_sandbox_workspace_setup"></a> [sandbox\_workspace\_setup](#module\_sandbox\_workspace\_setup) | ../../modules/databricks-workspace-setup | n/a |

## Resources

| Name | Type |
|------|------|

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id) | (Required) Databricks Client ID | `string` | n/a | yes |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret) | (Required) Databricks Client Secret | `string` | n/a | yes |
<!-- END_TF_DOCS -->