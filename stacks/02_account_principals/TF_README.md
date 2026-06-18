<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.14.1 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.90.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.90.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_project_data"></a> [project\_data](#module\_project\_data) | ../../modules/project_data | n/a |

## Resources

| Name | Type |
|------|------|
| [databricks_group.admins](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group) | resource |
| [databricks_group_member.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_group_role.my_group_account_admin](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_role) | resource |
| [databricks_service_principal.sp](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal) | resource |
| [databricks_user.admin_users](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id) | (Required) Databricks Client ID | `string` | n/a | yes |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret) | (Required) Databricks Client Secret | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databricks_group"></a> [databricks\_group](#output\_databricks\_group) | Databricks admin group name |
| <a name="output_databricks_user"></a> [databricks\_user](#output\_databricks\_user) | Databricks admin group ID |
<!-- END_TF_DOCS -->
