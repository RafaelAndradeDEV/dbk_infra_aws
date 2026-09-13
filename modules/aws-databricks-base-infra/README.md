# Module: `aws-databricks-base-infra`

Everything on the **AWS side** that a Databricks E2 workspace and Unity Catalog need, plus the account-level MWS registrations that point at it. Used by `stacks/01_infra`.

## Files

| File | Creates |
|------|---------|
| `vpc.tf` | VPC (via `terraform-aws-modules/vpc` 5.7.0), public/private subnets, IGW, single NAT, default SG, egress SG, VPC endpoints (S3 gateway + interface, STS, Kinesis), optional back-end PrivateLink endpoints/SGs, `databricks_mws_vpc_endpoint`, `databricks_mws_private_access_settings` |
| `cross_account_role.tf` | `<prefix>-crossaccount` IAM role (trust + policy from the `databricks_aws_*_policy` data sources) → `databricks_mws_credentials` |
| `root_bucket.tf` | Root/metastore bucket (or lookup if `reuse_metastore`), SSE, public access block, bucket policy (TLS-only, Databricks access conditioned on `DatabricksAccountId` tag, DBFS denied on `/metastore/*`) → `databricks_mws_storage_configurations` |
| `storage_configuration_role.tf` | `<prefix>-unity-catalog-rl` UC role, S3 access to the root bucket, managed file-events permissions (SNS/SQS), SelfAssume trust applied through `local-exec` |
| `storage_credential_infra.tf` | Per `storage_credential_configs` key: data-access IAM role + scoped S3/SNS/SQS policy, and the bucket via `./storage_bucket` when `create_bucket` |
| `storage_bucket/` | Submodule for a hardened S3 bucket. See [storage_bucket/README.md](storage_bucket/README.md) |

## Inputs (summary)

| Input | Description |
|-------|-------------|
| `prefix`, `tags`, `aws_region`, `databricks_account_id` | Naming, tagging, placement |
| `cidr_block`, `private_subnet_prefix_length` (17–26), `subnet_block_to_create` | Network sizing |
| `metastore_bucket_name`, `reuse_metastore` | Root/metastore bucket |
| `storage_credential_configs` | Map of `{name, bucket_name, create_bucket, prefix}` |
| `enable_backend_private_link`, `*_endpoint_service`, `private_access_public_access_enabled`, `databricks_dataplane_security_group_id` | PrivateLink |
| `databricks_uc_master_role_arn` | Override for GovCloud |

Requires the `aws`, `databricks` (**account-level**) and `time` providers. The AWS CLI must be available at apply time.

Generated reference: [TF_README.md](TF_README.md)
