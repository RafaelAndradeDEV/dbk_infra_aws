# Module: `aws-databricks-unity-catalog`

Creates (or looks up) a **Unity Catalog metastore** and its **default data access** configuration. Used by `stacks/03_uc_metastore`.

## Resources

| Resource | Notes |
|----------|-------|
| `data.aws_s3_bucket.metastore` | The bucket must already exist (created by `01_infra`) |
| `databricks_metastore.this` | Created when `reuse_metastore = false`. `storage_root = s3://<bucket>/metastore`, `owner = metastore_owner` |
| `data.databricks_metastore.existing` | Used when `reuse_metastore = true` |
| `databricks_metastore_data_access.this` | `<prefix>-metastore-data-access`, `is_default = true`, IAM role = `storage_configuration_role_arn` |

## Inputs

| Input | Required | Description |
|-------|:--------:|-------------|
| `prefix` | ✔ | Name prefix |
| `metastore_region` | ✔ | AWS region |
| `metastore_owner` | ✔ | Group/user that owns the metastore (the account admin group) |
| `metastore_bucket` | ✔ | Bucket name, no `s3://` |
| `storage_configuration_role_arn` | ✔ | UC IAM role from `01_infra` |
| `metastore_name` | | Defaults to `<prefix>-metastore` |
| `reuse_metastore` / `existing_metastore_id` | | Attach to an existing metastore |

## Output

`metastore_id`

Requires the **account-level** `databricks` provider.

Generated reference: [TF_README.md](TF_README.md)
