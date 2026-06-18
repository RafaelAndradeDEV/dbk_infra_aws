# lookup existing dev schemas in the catalog to avoid trying to create schemas that already exist
locals {
  sanitized_dev_schema_by_user = {
    for user in var.users : user.name => "dev_${replace(replace(lower(user.name), "/[^a-z0-9]+/", "_"), "^_+|_+$", "")}"
  }
}
resource "databricks_schema" "dev_schemas" {
  provider   = databricks.workspace
  depends_on = [databricks_catalog.catalogs]
  for_each   = var.dev_schema_catalog_name != null ? { for user in var.users : user.name => user } : {}

  catalog_name = var.dev_schema_catalog_name
  name         = local.sanitized_dev_schema_by_user[each.key]
  owner        = each.value.email
  comment      = "Developer schema for ${each.value.name}"
  properties = {
    managed_by = "terraform"
  }
}
