# Workspace configuration

## Permission assignment: add admin group as workspace admin
resource "databricks_permission_assignment" "add_admin_spn" {
  provider     = databricks.workspace
  principal_id = var.admin_group_principal_id
  permissions  = ["ADMIN"]
}

resource "databricks_catalog" "catalogs" {
  provider   = databricks.workspace
  depends_on = [databricks_permission_assignment.add_admin_spn]
  for_each   = { for c in var.catalogs : c.name => c }

  name           = each.value.name
  comment        = each.value.purpose
  isolation_mode = upper(each.value.isolation_mode)
  storage_root   = try(each.value.storage_root, null)
  properties = {
    managed_by = "terraform"
  }
}
