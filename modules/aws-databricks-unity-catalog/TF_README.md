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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.90.0 |

## Resources

| Name | Type |
|------|------|
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metastore_bucket"></a> [metastore\_bucket](#input\_metastore\_bucket) | Existing S3 bucket name to use for UC metastore (no s3:// prefix) | `string` | n/a | yes |
| <a name="input_metastore_name"></a> [metastore\_name](#input\_metastore\_name) | (Optional) Name of the metastore that will be created | `string` | `null` | no |
| <a name="input_metastore_owner"></a> [metastore\_owner](#input\_metastore\_owner) | (Required) Name of the principal that will be the owner of the Metastore | `string` | n/a | yes |
| <a name="input_metastore_region"></a> [metastore\_region](#input\_metastore\_region) | (Required) AWS region for the Unity Catalog metastore | `string` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | (Required) Prefix to name the resources created by this module | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id) | Unity Catalog Metastore ID |
<!-- END_TF_DOCS -->
