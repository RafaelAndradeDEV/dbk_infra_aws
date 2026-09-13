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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.50.0 |
| <a name="provider_databricks.mws"></a> [databricks.mws](#provider\_databricks.mws) | 1.117.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_project_data"></a> [project\_data](#module\_project\_data) | ../../modules/project_data | n/a |
| <a name="module_unity_catalog"></a> [unity\_catalog](#module\_unity\_catalog) | ../../modules/aws-databricks-unity-catalog | n/a |

## Resources

| Name | Type |
|------|------|
| [databricks_storage_credential.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [terraform_data.update_storage_role_trust_policy](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databricks_client_id"></a> [databricks\_client\_id](#input\_databricks\_client\_id) | (Required) Databricks Client ID | `string` | n/a | yes |
| <a name="input_databricks_client_secret"></a> [databricks\_client\_secret](#input\_databricks\_client\_secret) | (Required) Databricks Client Secret | `string` | n/a | yes |
| <a name="input_databricks_uc_master_role_arn"></a> [databricks\_uc\_master\_role\_arn](#input\_databricks\_uc\_master\_role\_arn) | (Optional) Databricks UC master role ARN (default: commercial AWS). | `string` | `"arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"` | no |
| <a name="input_existing_metastore_id"></a> [existing\_metastore\_id](#input\_existing\_metastore\_id) | (Optional) ID of an existing Unity Catalog metastore to attach to. Required when metastore\_config.reuse\_metastore is true in configs/project\_configs.yml. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | Unity Catalog metastore ID |
| <a name="output_storage_credentials"></a> [storage\_credentials](#output\_storage\_credentials) | Map of created Databricks storage credentials (keyed by config key) |
<!-- END_TF_DOCS -->