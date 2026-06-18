# Create schemas across specified catalogs
# This flattens the schema-to-catalogs mapping into individual schema resources
locals {
  # Flatten the schemas list to create a schema for each schema-catalog combination
  schemas_flat = flatten([
    for schema in var.schemas : [
      for catalog in schema.catalogs : {
        schema_name  = schema.name
        catalog_name = catalog
        key          = "${catalog}.${schema.name}"
        storage_root = try(schema.storage_root, null)
      }
    ]
  ])

  # Convert to map for for_each
  schemas_map = { for s in local.schemas_flat : s.key => s }
}


resource "databricks_schema" "schemas" {
  provider   = databricks.workspace
  depends_on = [databricks_catalog.catalogs]
  for_each   = local.schemas_map

  catalog_name = each.value.catalog_name
  name         = each.value.schema_name
  comment      = "Schema ${each.value.schema_name} in catalog ${each.value.catalog_name}"
  storage_root = try(each.value.storage_root, null)
  properties = {
    managed_by = "terraform"
  }
}
