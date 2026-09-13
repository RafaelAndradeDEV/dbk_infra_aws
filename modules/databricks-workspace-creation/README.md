# Module: `databricks-workspace-creation`

Provisions a Databricks **E2 workspace in a customer-managed VPC** through the account (MWS) API.

## Resources

| Resource | Notes |
|----------|-------|
| `databricks_mws_networks.this` | `<workspace_name>-network`: VPC, private subnets (≥ 2 AZs) and security groups |
| `databricks_mws_workspaces.this` | `PREMIUM` pricing tier. Uses the credentials and storage configuration from `01_infra`. `custom_tags` are propagated to AWS resources Databricks creates |

`lifecycle.ignore_changes` on `workspace_name` / `network_name` prevents a rename in YAML from forcing a workspace **replacement**.

## Inputs

| Input | Description |
|-------|-------------|
| `workspace_name`, `prefix` | Name (falls back to `prefix`) |
| `region`, `databricks_account_id` | Placement |
| `databricks_credentials_id`, `databricks_storage_configuration_id` | From `01_infra` outputs |
| `vpc_id`, `private_subnet_ids`, `security_group_ids` | From `01_infra` outputs |
| `tags` | Workspace custom tags |

## Outputs

| Output | Description |
|--------|-------------|
| `databricks_host` | Workspace URL. Used to configure the workspace-level provider |
| `databricks_workspace_id` | Numeric workspace ID |

Requires the `databricks.mws` provider alias.

Generated reference: [TF_README.md](TF_README.md)
