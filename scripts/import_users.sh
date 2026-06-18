#!/bin/bash

# Script to import existing Databricks schemas into Terraform state
# Assumes:
# - Catalog name: mesh_dev_db
# - Terraform resource address prefix: module.workspace_setup.module.databricks_workspace_configuration.databricks_schema.dev_schemas
# - Run this in the directory where terraform apply is typically run (e.g., where your .tf files are)
# - Terraform is installed and configured with the necessary providers/state

# Map of schema names to user full names
declare -A schema_to_user=(
  ["dev_vitor_avancini"]="Vitor Avancini"
  ["dev_gabriel_bernardo"]="Gabriel Bernardo"
  ["dev_guilherme_tavares"]="Guilherme Tavares"
  ["dev_nikolas_santos"]="Nikolas Santos"
  ["dev_vitor_gerber_weiss"]="Vitor Gerber Weiss"
  ["dev_artur_wagner"]="Artur Wagner"
  ["dev_thiago_figueiredo"]="Thiago Figueiredo"
  ["dev_andre_pegoraro"]="Andre Pegoraro"
  ["dev_luzia_souza"]="Luzia Souza"
  ["dev_gabriel_souza"]="Gabriel Souza"
  ["dev_guilherme_zanotelli"]="Guilherme Zanotelli"
)

# Catalog name (adjust if different for your workspace)
CATALOG="mesh_dev_db"

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
