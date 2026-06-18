locals {
  workspace_name_effective = coalesce(var.workspace_name, var.prefix)
  network_name             = "${local.workspace_name_effective}-network"
}

# Workspace Creation
## Workspace-specific configuration
resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = local.network_name
  security_group_ids = var.security_group_ids
  subnet_ids         = var.private_subnet_ids
  vpc_id             = var.vpc_id

  lifecycle {
    ignore_changes = [network_name]
  }
}

## Workspace creation
resource "databricks_mws_workspaces" "this" {
  provider                 = databricks.mws
  depends_on               = [databricks_mws_networks.this]
  account_id               = var.databricks_account_id
  aws_region               = var.region
  workspace_name           = local.workspace_name_effective
  credentials_id           = var.databricks_credentials_id
  storage_configuration_id = var.databricks_storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id
  pricing_tier             = "PREMIUM"
  custom_tags              = var.tags

  lifecycle {
    ignore_changes = [workspace_name]
  }
}
