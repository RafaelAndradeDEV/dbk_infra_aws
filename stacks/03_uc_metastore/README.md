# Stack 03 — Unity Catalog Metastore

Creates (or reuses) the regional **Unity Catalog metastore** and the **storage credentials** that let UC reach external S3 buckets.

| | |
|---|---|
| **State key** | `uc/terraform.tfstate` |
| **Depends on** | `01_infra` (IAM role ARNs, bucket), `02_account_principals` (admin group used as owner) |
| **Consumed by** | `04_databricks_workspaces` (`metastore_id`) |
| **Provider** | `databricks.mws` (account level) + `aws` (for the policy documents) |

## What it creates

| File | Resources |
|------|-----------|
| `main.tf` → [`aws-databricks-unity-catalog`](../../modules/aws-databricks-unity-catalog/) | `databricks_metastore` (storage root `s3://<metastore_bucket>/metastore`, owner = admin group) and `databricks_metastore_data_access` (default, uses the UC role from 01) |
| `storage_credentials.tf` | One `databricks_storage_credential` per `storage_credential_configs` entry (`ISOLATED`), then a trust-policy rewrite for each matching IAM role |

## How the storage credential trust is finalized

1. `databricks_storage_credential` is created with the IAM role ARN from `01_infra`. Databricks returns a unique `external_id`.
2. `aws_iam_policy_document.storage_role_trust` builds the final trust policy:
   - **Databricks:** UC master role, `sts:ExternalId = <that external_id>`.
   - **SelfAssume:** the role can assume itself.
3. `terraform_data.update_storage_role_trust_policy` applies it with the AWS CLI. It runs again whenever the role ARN or the policy changes.

This is why the IAM role (stack 01) and the credential (stack 03) live in different stacks. The full explanation is in [docs/architecture.md](../../docs/architecture.md#the-chicken-and-egg-problem-and-how-its-solved).

## Reusing an existing metastore

Databricks allows **one metastore per region per account**. If one already exists:

1. Set `metastore_config.reuse_metastore: true` in `project_configs.yml`.
2. Put the existing metastore ID in `existing_metastore_id` in `main.tf`.
3. `01_infra` will then look up the existing bucket instead of creating one.

## Outputs

| Output | Description |
|--------|-------------|
| `metastore_id` | Assigned to every workspace in stack 04 |
| `storage_credentials` | Map `key → { id, name }` |

## Gotchas

- Needs the **AWS CLI** at apply time.
- `databricks_uc_master_role_arn` defaults to the commercial AWS UC master role. Override it for GovCloud.
- A credential is `ISOLATED`, so it's usable only in workspaces that list it under `storage_credential_names` in `workspace_configs.yml`.

Generated reference: [TF_README.md](TF_README.md)
