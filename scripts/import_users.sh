#!/bin/bash

# Script to import existing Databricks schemas into Terraform state
# Assumes:
# - Catalog name: project_dev_db
# - Terraform resource address prefix: module.workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas
# - Run this in the directory where terraform apply is typically run (e.g., where your .tf files are)
# - Terraform is installed and configured with the necessary providers/state

# Map of schema names to user full names
declare -A schema_to_user=(
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
  ["dev_example_user"]="Example User"
)

# Catalog name (adjust if different for your workspace)
CATALOG="project_dev_db"

# Loop over the schemas and run terraform import
for schema in "${!schema_to_user[@]}"; do
  user="${schema_to_user[$schema]}"
  resource_address="module.workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas[\"$user\"]"
  import_id="$CATALOG.$schema"

  echo "Importing schema for $user: $import_id"
  terraform import "$resource_address" "$import_id"

  # Optional: Add a short delay to avoid rate limiting if needed
  # sleep 1
done

echo "All imports completed. Run 'terraform plan' to verify."
