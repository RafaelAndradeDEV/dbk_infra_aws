module "account_principals_managed" {
  source = "../../modules/account-principals-managed"
  providers = {
    databricks.mws = databricks.mws
  }

  account_id         = module.project_data.databricks_account_id
  users              = module.project_data.account_users
  service_principals = module.project_data.account_service_principals
  groups             = module.project_data.account_groups
}
