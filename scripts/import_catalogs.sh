#!/bin/bash

# Script to import existing Databricks catalogs into Terraform state
# Assumes:
# - Terraform resource address format: module.<workspace_setup>.module.databricks_workspace_configuration.databricks_catalog.catalogs["<catalog_name>"]
# - Import ID is just the catalog name (e.g., project_prod_db)
# - Run this in the directory where terraform apply is typically run (e.g., stacks/04_databricks_workspaces)
# - Terraform is installed and configured with the necessary providers/state
# - Catalogs are grouped by workspace/module for correct addressing

# Define workspaces with their module names and catalogs
declare -A workspaces

# Mesh workspace
workspaces["workspace_setup"]="project_dev_db project_qa_db project_prod_db"

# Sandbox workspace
workspaces["sandbox_workspace_setup"]="sandbox_qa_db sandbox_prod_db"

# DS workspace
workspaces["ds_workspace_setup"]="ds_qa_db ds_prod_db"

# Loop over each workspace module
for module_name in "${!workspaces[@]}"; do
  catalogs="${workspaces[$module_name]}"
  for catalog in $catalogs; do
    resource_address="module.$module_name.module.databricks_workspace_configuration.databricks_catalog.catalogs[\"$catalog\"]"
    import_id="$catalog"

    echo "Importing catalog $catalog in module $module_name: $import_id"
    terraform import "$resource_address" "$import_id"

    # Optional: Add a short delay to avoid rate limiting if needed
    # sleep 1
  done
done

echo "All imports completed. Run 'terraform plan' to verify."
