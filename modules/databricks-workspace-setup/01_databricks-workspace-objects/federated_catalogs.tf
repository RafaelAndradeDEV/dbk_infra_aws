locals {
  fc_secrets = {
    for item in flatten([
      for fc in var.federated_catalogs : [
        for s in try(fc.secrets, []) : {
          key             = "${fc.name}:${s.option_key}"
          catalog_name    = fc.name
          option_key      = s.option_key
          secret_arn      = s.secret_arn
          secret_json_key = s.secret_json_key
        }
      ]
    ]) : item.key => item
  }
}

data "aws_secretsmanager_secret_version" "fc_secret" {
  provider  = aws
  for_each  = local.fc_secrets
  secret_id = each.value.secret_arn
}

resource "databricks_connection" "this" {
  provider        = databricks.workspace
  for_each        = { for fc in var.federated_catalogs : fc.name => fc }
  depends_on      = [databricks_permission_assignment.add_admin_spn]
  name            = each.value.name
  connection_type = each.value.connection_type
  comment         = try(each.value.comment, null)
  read_only       = try(each.value.read_only, false)

  options = merge(
    each.value.options,
    {
      for s in try(each.value.secrets, []) :
      s.option_key => jsondecode(
        data.aws_secretsmanager_secret_version.fc_secret["${each.key}:${s.option_key}"].secret_string
      )[s.secret_json_key]
    }
  )
}

resource "databricks_catalog" "federated" {
  provider        = databricks.workspace
  for_each        = { for fc in var.federated_catalogs : fc.name => fc }
  depends_on      = [databricks_permission_assignment.add_admin_spn]
  name            = each.value.name
  comment         = try(each.value.comment, null)
  connection_name = databricks_connection.this[each.key].name

  options = try(each.value.catalog_options, {})
}
