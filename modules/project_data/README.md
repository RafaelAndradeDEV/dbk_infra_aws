# Module: `project_data`

The **configuration layer**. It has no resources and no inputs: it reads `configs/*.yml`, normalizes them and exposes the results as outputs. Every stack instantiates it first.

```
module "project_data" {
  source = "../../modules/project_data"
}
```

## What it does

| Step | Detail |
|------|--------|
| Load | `yamldecode(file(...))` on `project_configs.yml`, `principal_configs.yml`, `workspace_configs.yml` (paths relative to the module, so this works from any stack) |
| Defaults | Fills in every optional field (see [docs/configuration.md](../../docs/configuration.md)) |
| Sanitize | Changes `-` to `_` in catalog, schema, external location and federated catalog names. Upper-cases `isolation_mode`. Drops empty or null tag entries |
| Tags | `default_tags` = `{Source, Region, Env, Project}` merged with `default_tags` from YAML |
| Derive | `workspace_account_groups` (per-workspace group grants in the shape `databricks-workspace-setup` expects) and `workspace_users` (users whose groups are assigned to the workspace) |

## Most used outputs

| Output | Used by |
|--------|---------|
| `project_name`, `aws_region`, `databricks_account_id`, `default_tags` | All stacks |
| `backend_state_bucket_name` | `00`, and remote-state lookups in `03`/`04` |
| `network_cidr_block`, `storage_credential_configs`, PrivateLink settings | `01` |
| `account_users`, `account_groups`, `account_service_principals`, `account_admin_group` | `02`, `03`, `04` |
| `metastore_config` | `01`, `03` |
| `workspaces` (map by name), `workspace_account_groups`, `workspace_users` | `04` |

`workspace_name`, `workspace_groups` and `workspace_service_principals` are legacy single-workspace outputs, kept for backward compatibility.

Generated reference: [TF_README.md](TF_README.md)
