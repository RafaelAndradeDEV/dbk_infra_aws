# Stack 04 — Databricks Workspaces

Creates each **Databricks workspace** and configures everything inside it: Unity Catalog attachment, external locations, catalogs, schemas, compute, permissions and budgets.

| | |
|---|---|
| **State key** | `workspaces/terraform.tfstate` |
| **Depends on** | `01_infra` (network, credentials, storage config), `02_account_principals` (groups), `03_uc_metastore` (metastore ID) |
| **Source of truth** | [`configs/workspace_configs.yml`](../../configs/workspace_configs.yml) |

## Files

| File | Purpose |
|------|---------|
| `main.tf` | `project_data`, remote state for `infra` and `uc`, lookup of the account admin group |
| `provider.tf` | Backend, `aws`, account-level `databricks.mws`, `time` |
| `locals.tf` | Workspace names and **subnet allocation** per workspace |
| `aws_sandbox.tf` | The `project-sandbox` workspace: creation module, workspace provider, setup module |

## What each workspace gets

```
databricks-workspace-creation
  ├── databricks_mws_networks       (VPC, 2 private subnets, SG)
  └── databricks_mws_workspaces     (PREMIUM, custom tags)

databricks-workspace-setup
  ├── metastore assignment + storage-credential bindings
  ├── external locations (with managed file events)
  ├── 01_databricks-workspace-objects
  │     ├── admin group → workspace ADMIN
  │     ├── catalogs, schemas, per-user dev schemas
  │     ├── default + configured SQL warehouses
  │     ├── all-purpose clusters
  │     └── federated catalogs (optional)
  ├── 02_workspace-group-attachments
  │     ├── group → workspace assignment (ADMIN/USER)
  │     ├── UC grants: catalog, schema, external location, storage credential
  │     └── cluster + SQL warehouse ACLs
  └── budgets (workspace + optional AI Gateway)
```

## Adding a new workspace

1. **YAML:** add an entry under `workspaces:` in `configs/workspace_configs.yml`. Create its groups in `principal_configs.yml`.
2. **Subnets:** in `locals.tf`, add a name and **two unused private subnets in different AZs**:

   ```
   analytics_workspace_name               = "project-analytics"
   analytics_workspace_private_subnet_ids = [local.private_subnet_all[2], local.private_subnet_all[3]]
   ```

3. **Wiring:** copy `aws_sandbox.tf` to `aws_<name>.tf`, then rename:
   - the module labels (`<name>_workspace_creation`, `<name>_workspace_setup`)
   - the provider alias (`databricks.<name>_workspace`)
   - the `local.*` references
4. **Apply:** `terraform apply` in this stack, or run the targeted workflow with `workspaces`.

`01_infra` pre-creates 10 private subnets, which is enough for 5 workspaces.

## Usage

```
cd stacks/04_databricks_workspaces
terraform init
terraform apply
```

The first apply for a new workspace takes about 10–15 minutes while Databricks provisions it. The workspace provider is configured from the new workspace URL, so creation and setup happen in the same run.

## FAQ

### "Catalog / schema already exists"

The object was created outside Terraform, or by an earlier state. Import it:

```
# Catalog
terraform import \
  'module.sandbox_workspace_setup.module.databricks_workspace_configuration.databricks_catalog.catalogs["project_prod_db"]' \
  project_prod_db

# Shared schema (key = "<catalog>.<schema>")
terraform import \
  'module.sandbox_workspace_setup.module.databricks_workspace_configuration.databricks_schema.schemas["project_prod_db.raw"]' \
  project_prod_db.raw

# Developer schema (key = user display name)
terraform import \
  'module.sandbox_workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas["Rafael Andrade"]' \
  project_dev_db.dev_rafael_andrade
```

For bulk imports, see [scripts/README.md](../../scripts/README.md).

### A privilege I granted in the UI disappeared

This is expected. `databricks_grants` and `databricks_permissions` are authoritative. Add the privilege in `workspace_configs.yml` instead.

### "Cannot bind storage credential" / external location validation fails

The credential must be listed in the workspace's `storage_credential_names`, and stack 03 must have finished updating the IAM trust policy. Re-run `03_uc_metastore`, then this stack.

Generated reference: [TF_README.md](TF_README.md)
