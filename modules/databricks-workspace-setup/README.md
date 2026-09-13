# Module: `databricks-workspace-setup`

Configures an existing workspace: attaches it to Unity Catalog, creates data objects and compute, and applies all permissions and budgets. Split into two submodules so objects are created before grants reference them.

## Layout

| Path | Provider | Creates |
|------|----------|---------|
| `main.tf` | workspace + mws | `databricks_metastore_assignment`, `databricks_workspace_binding` (storage credentials), `databricks_external_location` (with optional file events), group lookups, `databricks_budget` (workspace and AI Gateway) |
| `01_databricks-workspace-objects/` | workspace (+ aws) | Admin group → workspace ADMIN, `databricks_catalog`, `databricks_schema` (shared + `dev_<user>`), `databricks_sql_endpoint` (default + configured), `databricks_cluster`, `databricks_connection` + foreign catalogs (secrets from AWS Secrets Manager) |
| `02_workspace-group-attachments/` | workspace | `databricks_permission_assignment` (ADMIN/USER), `databricks_grants` on catalogs/schemas/external locations/storage credentials, `databricks_permissions` on clusters and SQL warehouses |

## Dependency order

```
metastore assignment → storage credential bindings → external locations
   → workspace objects (catalogs, schemas, compute)
   → group attachments (assignments → 5s wait → grants and ACLs)
```

## Defaults worth knowing

| Object | Default |
|--------|---------|
| Default SQL warehouse | `<workspace>-default-sql-wh`, PRO, 2X-Small, max 3 clusters, auto-stop 10 min, not serverless |
| Cluster | Spark 4 LTS (Scala 2.13), smallest local-disk node, autoscale 1–2, auto-terminate 15 min, `DATA_SECURITY_MODE_STANDARD`, pinned |
| Dev schema name | `dev_` + the user's display name lower-cased, with non-alphanumerics changed to `_` (for example `Rafael Andrade` → `dev_rafael_andrade`) |
| Budget | Only created when `budget_amount > 0`. Monthly cumulative list-price alert, filtered on this workspace ID |

## Providers

Requires `aws`, `databricks.workspace` (workspace URL) and `databricks.mws` (account).

All inputs are normally supplied from `module.project_data` in `stacks/04_databricks_workspaces`. The full list is in [`variables.tf`](variables.tf).

Generated reference: [TF_README.md](TF_README.md)
