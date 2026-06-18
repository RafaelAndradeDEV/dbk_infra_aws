locals {
  admin_group = module.project_data.account_admin_group
}

resource "databricks_group" "admins" {
  provider     = databricks.mws
  display_name = local.admin_group
}

resource "databricks_group_role" "my_group_account_admin" {
  provider = databricks.mws
  group_id = databricks_group.admins.id
  role     = "account_admin"
}
