# Scripts

| Script | Purpose |
|--------|---------|
| [`setup.sh`](setup.sh) | Installs **tfenv** → Terraform (from `.terraform-version`), **TFLint** and **pre-commit**, then enables the git hooks. Supports Ubuntu/Debian and macOS. Run it from the repo root: `bash scripts/setup.sh` |
| [`install-terraform-docs.sh`](install-terraform-docs.sh) | Installs `terraform-docs` (default `v0.20.0`) for regenerating `TF_README.md`. Override with `TERRAFORM_DOCS_VERSION` / `INSTALL_DIR` |
| [`import_catalogs.sh`](import_catalogs.sh) | Template for bulk `terraform import` of existing catalogs into stack 04 |
| [`import_users.sh`](import_users.sh) | Template for bulk `terraform import` of existing developer schemas (`dev_<name>`) into stack 04 |

## Using the import templates

The import scripts are **templates**. Before running one:

1. Edit the module names to match your stack. The sandbox workspace uses `sandbox_workspace_setup`.
2. Edit the catalog/schema names.
3. Run it from `stacks/04_databricks_workspaces` after `terraform init`.
4. Run `terraform plan` afterwards. It should show no changes for the imported objects.

Resource address format:

```
module.<ws>_workspace_setup.module.databricks_workspace_configuration.databricks_catalog.catalogs["<catalog>"]
module.<ws>_workspace_setup.module.databricks_workspace_configuration.databricks_schema.schemas["<catalog>.<schema>"]
module.<ws>_workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas["<User Display Name>"]
```
