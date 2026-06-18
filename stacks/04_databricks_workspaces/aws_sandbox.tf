module "sandbox_workspace_creation" {
  source = "../../modules/databricks-workspace-creation"
  providers = {
    databricks.mws = databricks.mws
  }

  workspace_name                      = local.sandbox_workspace_name
  prefix                              = module.project_data.project_name
  region                              = module.project_data.aws_region
  databricks_account_id               = module.project_data.databricks_account_id
  databricks_credentials_id           = data.terraform_remote_state.infra.outputs.databricks_credentials_id
  databricks_storage_configuration_id = data.terraform_remote_state.infra.outputs.databricks_storage_configuration_id
  security_group_ids                  = local.security_group_ids
  private_subnet_ids                  = local.sandbox_workspace_private_subnet_ids
  vpc_id                              = data.terraform_remote_state.infra.outputs.vpc_id
  tags                                = module.project_data.default_tags
}

# Workspace specific provider
provider "databricks" {
  alias         = "sandbox_workspace"
  host          = module.sandbox_workspace_creation.databricks_host
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}

module "sandbox_workspace_setup" {
  source = "../../modules/databricks-workspace-setup"
  providers = {
    aws                  = aws
    databricks.workspace = databricks.sandbox_workspace
    databricks.mws       = databricks.mws
  }

  workspace_id             = module.sandbox_workspace_creation.databricks_workspace_id
  workspace_name           = local.sandbox_workspace_name
  account_groups           = try(module.project_data.workspace_account_groups[local.sandbox_workspace_name], [])
  all_purpose_clusters     = try(module.project_data.workspaces[local.sandbox_workspace_name].all_purpose_clusters, [])
  cluster_tags             = try(module.project_data.workspaces[local.sandbox_workspace_name].cluster_tags, {})
  sql_endpoint_tags        = try(module.project_data.workspaces[local.sandbox_workspace_name].sql_endpoint_tags, {})
  default_sql_wh_name      = "${replace(local.sandbox_workspace_name, "_", "-")}-default-sql-wh"
  sql_warehouses           = try(module.project_data.workspaces[local.sandbox_workspace_name].sql_warehouses, [])
  catalogs                 = try(module.project_data.workspaces[local.sandbox_workspace_name].catalogs, [])
  schemas                  = try(module.project_data.workspaces[local.sandbox_workspace_name].schemas, [])
  admin_group_principal_id = data.databricks_group.account_admin_group.id
  metastore_id             = data.terraform_remote_state.metastore.outputs.metastore_id
  dev_schema_catalog_name  = try(module.project_data.workspaces[local.sandbox_workspace_name].dev_catalog_name, null)
  users                    = try(module.project_data.workspace_users[local.sandbox_workspace_name], [])

  external_locations       = try(module.project_data.workspaces[local.sandbox_workspace_name].external_locations, [])
  storage_credential_names = try(module.project_data.workspaces[local.sandbox_workspace_name].storage_credential_names, [])

  budget_amount              = try(module.project_data.workspaces[local.sandbox_workspace_name].budget_amount, 0)
  budget_notification_emails = try(module.project_data.workspaces[local.sandbox_workspace_name].budget_notification_emails, [])

  federated_catalogs = try(module.project_data.workspaces[local.sandbox_workspace_name].federated_catalogs, [])
}
