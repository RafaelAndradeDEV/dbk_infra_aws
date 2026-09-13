#!/bin/bash
# Import existing per-developer schemas (dev_<name>) into Terraform state.
#
# Usage:
#   Run from stacks/04_databricks_workspaces (after `terraform init`).
#   Set CATALOG and MODULE below, and list the users exactly as their
#   display names appear in configs/principal_configs.yml.
#
# Resource address (map key is the user's DISPLAY NAME):
#   module.<module>.module.databricks_workspace_configuration.databricks_schema.dev_schemas["<Display Name>"]
# Import ID is "<catalog>.<schema>", where the schema is the display name
# lower-cased with non-alphanumerics replaced by "_" (e.g. "Ada Lovelace" -> dev_ada_lovelace).

set -euo pipefail

CATALOG="project_dev_db"
MODULE="sandbox_workspace_setup"

users=(
  "Ada Lovelace"
  # "Another User"
)

for user in "${users[@]}"; do
  schema="dev_$(echo "$user" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g; s/^_+|_+$//g')"
  resource_address="module.$MODULE.module.databricks_workspace_configuration.databricks_schema.dev_schemas[\"$user\"]"

  echo "Importing schema for '$user': $CATALOG.$schema"
  terraform import "$resource_address" "$CATALOG.$schema"
done

echo "All imports completed. Run 'terraform plan' to verify (expect no changes)."
