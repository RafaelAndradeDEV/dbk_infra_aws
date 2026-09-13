#!/bin/bash
# Import existing Unity Catalog catalogs into Terraform state.
#
# Usage:
#   Run from stacks/04_databricks_workspaces (after `terraform init`).
#   Edit the `workspaces` map below: key = workspace setup module name,
#   value = space-separated catalog names to import.
#
# Resource address:
#   module.<module>.module.databricks_workspace_configuration.databricks_catalog.catalogs["<catalog>"]
# Import ID is the catalog name itself.

set -euo pipefail

declare -A workspaces
workspaces["sandbox_workspace_setup"]="project_dev_db project_qa_db project_prod_db"

for module_name in "${!workspaces[@]}"; do
  for catalog in ${workspaces[$module_name]}; do
    resource_address="module.$module_name.module.databricks_workspace_configuration.databricks_catalog.catalogs[\"$catalog\"]"

    echo "Importing catalog '$catalog' into module '$module_name'"
    terraform import "$resource_address" "$catalog"
  done
done

echo "All imports completed. Run 'terraform plan' to verify (expect no changes)."
