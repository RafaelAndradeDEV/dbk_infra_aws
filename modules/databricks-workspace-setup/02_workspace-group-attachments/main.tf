locals {
  groups_for_workspace = { for g in var.account_groups : g.group_name => g if contains(try(g.workspaces, []), var.workspace_name) }

  principals_for_assignment = { for name, g in local.groups_for_workspace : name => var.group_principal_ids[name] if contains(keys(var.group_principal_ids), name) }
  workspace_permissions     = { for name, g in local.groups_for_workspace : name => try(g.workspace_permissions[var.workspace_name], try(g.workspace_permissions, ["USER"])) }

  cluster_privileges = flatten([
    for gname, g in local.groups_for_workspace : [
      for cp in coalesce(g.cluster_privileges, []) : {
        group_name   = gname
        cluster_name = cp.cluster_name
        privileges   = cp.privileges
      }
    ]
  ])
  flattened_cluster_privileges = flatten([
    for p in local.cluster_privileges : [
      for priv in p.privileges : {
        group_name   = p.group_name
        cluster_name = p.cluster_name
        privilege    = priv
      }
    ]
  ])
  cluster_permissions_by_cluster = {
    for cluster_name in toset([for p in local.flattened_cluster_privileges : p.cluster_name]) : cluster_name => {
      permissions = [
        for p_inner in local.flattened_cluster_privileges : {
          group_name = p_inner.group_name
          privilege  = p_inner.privilege
        } if p_inner.cluster_name == cluster_name
      ]
    }
  }

  catalog_grants = flatten([
    for gname, g in local.groups_for_workspace : [
      for priv in coalesce(g.catalog_privileges, []) : {
        principal    = gname
        catalog_name = priv.catalog_name
        privileges   = priv.privileges
      }
    ]
  ])
  grants_by_catalog = {
    for cname in toset([for g in local.catalog_grants : g.catalog_name]) : cname => {
      grants = [for g in local.catalog_grants : { principal = g.principal, privileges = g.privileges } if g.catalog_name == cname]
    }
  }

  schema_grants = flatten([
    for gname, g in local.groups_for_workspace : [
      for priv in coalesce(g.schema_privileges, []) : {
        principal    = gname
        catalog_name = priv.catalog_name
        schema_name  = priv.schema_name
        privileges   = priv.privileges
      }
    ]
  ])
  grants_by_schema = {
    for key in toset([for g in local.schema_grants : "${g.catalog_name}.${g.schema_name}"]) : key => {
      catalog_name = split(".", key)[0]
      schema_name  = split(".", key)[1]
      grants       = [for g in local.schema_grants : { principal = g.principal, privileges = g.privileges } if "${g.catalog_name}.${g.schema_name}" == key]
    }
  }

  external_location_grants = flatten([
    for gname, g in local.groups_for_workspace : [
      for priv in coalesce(g.external_location_privileges, []) : {
        principal              = gname
        external_location_name = priv.external_location_name
        privileges             = priv.privileges
      }
    ]
  ])
  grants_by_external_location = {
    for lname in toset([for g in local.external_location_grants : g.external_location_name]) : lname => {
      grants = [
        for g in local.external_location_grants : { principal = g.principal, privileges = g.privileges }
        if g.external_location_name == lname
      ]
    }
  }

  storage_credential_grants = flatten([
    for gname, g in local.groups_for_workspace : [
      for priv in coalesce(g.storage_credential_privileges, []) : {
        principal               = gname
        storage_credential_name = priv.storage_credential_name
        privileges              = priv.privileges
      }
      # Only include grants for storage credentials that are bound to this workspace
      if contains(var.bound_storage_credential_names, priv.storage_credential_name)
    ]
  ])
  grants_by_storage_credential = {
    for cname in toset([for g in local.storage_credential_grants : g.storage_credential_name]) : cname => {
      grants = [
        for g in local.storage_credential_grants : { principal = g.principal, privileges = g.privileges }
        if g.storage_credential_name == cname
      ]
    }
  }
  sql_warehouse_privileges = flatten([
    for gname, g in local.groups_for_workspace : [
      for sp in coalesce(g.sql_warehouse_privileges, []) : {
        group_name     = gname
        warehouse_name = sp.warehouse_name
        privileges     = sp.privileges
      }
    ]
  ])
  flattened_sql_warehouse_privileges = flatten([
    for p in local.sql_warehouse_privileges : [
      for priv in p.privileges : {
        group_name     = p.group_name
        warehouse_name = p.warehouse_name
        privilege      = priv
      }
    ]
  ])
  sql_warehouse_permissions_by_warehouse = {
    for warehouse_name in toset([for p in local.flattened_sql_warehouse_privileges : p.warehouse_name]) : warehouse_name => {
      permissions = [
        for p_inner in local.flattened_sql_warehouse_privileges : {
          group_name = p_inner.group_name
          privilege  = p_inner.privilege
        } if p_inner.warehouse_name == warehouse_name
      ]
    }
  }

}

resource "databricks_permission_assignment" "group_workspace" {
  provider     = databricks.workspace
  for_each     = local.principals_for_assignment
  principal_id = tostring(each.value.id)
  permissions  = try(local.workspace_permissions[each.key], ["USER"])
}

resource "time_sleep" "wait_after_workspace_assignment" {
  depends_on      = [databricks_permission_assignment.group_workspace]
  create_duration = "5s"
}

resource "databricks_permissions" "cluster_usage" {
  provider   = databricks.workspace
  depends_on = [time_sleep.wait_after_workspace_assignment]
  for_each   = local.cluster_permissions_by_cluster
  cluster_id = var.cluster_ids[each.key]

  dynamic "access_control" {
    for_each = each.value.permissions
    content {
      group_name       = access_control.value.group_name
      permission_level = access_control.value.privilege
    }
  }
}

resource "databricks_grants" "catalog" {
  provider   = databricks.workspace
  depends_on = [time_sleep.wait_after_workspace_assignment]
  for_each   = var.apply_catalog_grants ? local.grants_by_catalog : {}
  catalog    = each.key

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_grants" "schema" {
  provider   = databricks.workspace
  depends_on = [time_sleep.wait_after_workspace_assignment]
  for_each   = local.grants_by_schema
  schema     = "${each.value.catalog_name}.${each.value.schema_name}"

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_grants" "external_location" {
  provider          = databricks.workspace
  depends_on        = [time_sleep.wait_after_workspace_assignment]
  for_each          = local.grants_by_external_location
  external_location = each.key

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_grants" "storage_credential" {
  provider           = databricks.workspace
  depends_on         = [time_sleep.wait_after_workspace_assignment]
  for_each           = local.grants_by_storage_credential
  storage_credential = each.key

  dynamic "grant" {
    for_each = each.value.grants
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_permissions" "sql_warehouse_usage" {
  provider        = databricks.workspace
  depends_on      = [time_sleep.wait_after_workspace_assignment]
  for_each        = local.sql_warehouse_permissions_by_warehouse
  sql_endpoint_id = var.sql_warehouse_ids[each.key]
  dynamic "access_control" {
    for_each = each.value.permissions
    content {
      group_name       = access_control.value.group_name
      permission_level = access_control.value.privilege
    }
  }
}
