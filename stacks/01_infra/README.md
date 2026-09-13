# Stack 01 — AWS Infrastructure

Builds the **AWS side** of the platform and registers it with the Databricks account. Everything comes from [`modules/aws-databricks-base-infra`](../../modules/aws-databricks-base-infra/).

| | |
|---|---|
| **State key** | `infra/terraform.tfstate` |
| **Depends on** | `00_bootstrap` (backend bucket) |
| **Consumed by** | `03_uc_metastore`, `04_databricks_workspaces` via `terraform_remote_state` |
| **Providers** | `aws`, `databricks.mws` (account), `time` |

## What it creates

| Area | Resources |
|------|-----------|
| **Network** | VPC `10.20.0.0/16`, 1 public and 10 private `/24` subnets, IGW, single NAT gateway, default SG (intra-SG + all egress), egress-only SG |
| **VPC endpoints** | S3 Gateway, S3 Interface (private DNS), STS, Kinesis Streams |
| **Workspace IAM** | Cross-account role `<prefix>-crossaccount` with the Databricks-generated policy → `databricks_mws_credentials` |
| **Root storage** | Root/metastore bucket (TLS-only, SSE, DBFS denied on `/metastore/*`) → `databricks_mws_storage_configurations` |
| **Unity Catalog IAM** | `<prefix>-unity-catalog-rl` (metastore role, root bucket access + file-events SNS/SQS). The trust policy is finalized with SelfAssume |
| **Storage credentials (AWS side)** | Per `storage_credential_configs` entry: IAM role `<prefix>-uc-access-<key>` scoped to its bucket/prefix, plus the bucket if `create_bucket: true` |
| **Optional PrivateLink** | Workspace/relay/service-direct interface endpoints, their SGs, `databricks_mws_vpc_endpoint` ×2, `databricks_mws_private_access_settings` (only if `enable_backend_private_link: true`) |

## Key settings (in `main.tf`)

| Setting | Value | Meaning |
|---------|-------|---------|
| `private_subnet_prefix_length` | `24` | 256 IPs per subnet, enough for roughly 250 cluster nodes per workspace subnet pair |
| `subnet_block_to_create` | `10` | Private subnets to pre-create (2 per workspace → room for 5 workspaces) |

## Outputs used downstream

`vpc_id`, `private_subnet_ids`, `security_group_ids`, `databricks_credentials_id`, `databricks_storage_configuration_id`, `storage_configuration_role_arn`, `storage_data_access_role_names`, `storage_data_access_role_arns`, `storage_credential_configs`, `storage_buckets`

## Usage

```
cd stacks/01_infra
terraform init
terraform plan
terraform apply
```

## Gotchas

- **The AWS CLI must be installed** where `apply` runs. `terraform_data.update_trust_policy` calls `aws iam update-assume-role-policy`.
- `privatelink.tf` has a precondition that fails the plan if PrivateLink is enabled but the endpoint service names are missing or belong to a different region.
- `cross_account_role.tf` attaches an extra `iam:PassRole` policy for a fixed ECR pipeline role. Remove or change it for your own account.

Generated reference: [TF_README.md](TF_README.md)
