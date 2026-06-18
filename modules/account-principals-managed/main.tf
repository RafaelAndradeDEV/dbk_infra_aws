locals {
  users_by_email   = { for u in var.users : u.email => u }
  groups_to_create = { for g in var.groups : g.group_name => g if try(coalesce(g.skip_create, false), false) == false }
  groups_to_lookup = { for g in var.groups : g.group_name => g if try(coalesce(g.skip_create, false), false) }
}

resource "databricks_user" "this" {
  provider                 = databricks.mws
  for_each                 = local.users_by_email
  user_name                = each.value.email
  display_name             = try(each.value.name, each.value.email)
  allow_cluster_create     = try(each.value.allow_cluster_create, false)
  disable_as_user_deletion = false
  force                    = true
}

resource "databricks_service_principal" "this" {
  provider                 = databricks.mws
  for_each                 = { for sp in var.service_principals : sp.name => sp }
  display_name             = coalesce(each.value.display_name, each.value.name)
  disable_as_user_deletion = false
  force                    = true
}

data "databricks_group" "existing" {
  provider     = databricks.mws
  for_each     = local.groups_to_lookup
  display_name = each.value.group_name
}

resource "databricks_group" "this" {
  provider              = databricks.mws
  for_each              = local.groups_to_create
  display_name          = each.value.group_name
  allow_cluster_create  = true
  databricks_sql_access = true
  workspace_access      = true
}

locals {
  group_name_to_id = merge(
    { for k, v in databricks_group.this : k => v.id },
    { for k, v in data.databricks_group.existing : k => v.id }
  )
  # Build memberships from the groups listed under users and service principals
  user_group_memberships = {
    for u in var.users : u.email => toset(try(u.groups, []))
  }
  sp_group_memberships = {
    for sp in var.service_principals : sp.name => toset(try(sp.groups, []))
  }

  user_memberships_flat = flatten([
    for email, groups in local.user_group_memberships : [
      for group in groups : {
        email = email
        group = group
      } if contains(keys(local.group_name_to_id), group)
    ]
  ])

  sp_memberships_flat = flatten([
    for sp_name, groups in local.sp_group_memberships : [
      for group in groups : {
        sp_name = sp_name
        group   = group
      } if contains(keys(local.group_name_to_id), group)
    ]
  ])

  # Useful for debugging: memberships requested in YAML but skipped because the group wasn't created/lookup'd by this module.
  user_memberships_dropped = flatten([
    for email, groups in local.user_group_memberships : [
      for group in groups : {
        email = email
        group = group
      } if !contains(keys(local.group_name_to_id), group)
    ]
  ])

  sp_memberships_dropped = flatten([
    for sp_name, groups in local.sp_group_memberships : [
      for group in groups : {
        sp_name = sp_name
        group   = group
      } if !contains(keys(local.group_name_to_id), group)
    ]
  ])
}

resource "databricks_group_member" "user_membership" {
  provider  = databricks.mws
  for_each  = { for m in local.user_memberships_flat : "${m.email}:${m.group}" => m }
  group_id  = local.group_name_to_id[each.value.group]
  member_id = databricks_user.this[each.value.email].id
}

resource "databricks_group_member" "sp_membership" {
  provider  = databricks.mws
  for_each  = { for m in local.sp_memberships_flat : "${m.sp_name}:${m.group}" => m }
  group_id  = local.group_name_to_id[each.value.group]
  member_id = databricks_service_principal.this[each.value.sp_name].id
}

locals {
  group_grant_rules_flat = {
    for g in var.groups : g.group_name => flatten([
      for gr in try(g.permissions, []) : [
        for r in gr.role : {
          role = r == "Manage" ? "roles/group.manager" : "roles/group.user"
          principals = [
            for p in gr.principals :
            p.type == "group" ? "groups/${local.group_name_to_id[p.name]}" :
            p.type == "user" ? "users/${p.name}" :
            "servicePrincipals/${p.name}"
          ]
        }
      ]
    ])
    if length(try(g.permissions, [])) > 0 && contains(keys(local.group_name_to_id), g.group_name)
  }

  sp_grant_rules_flat = {
    for sp in var.service_principals : sp.name => flatten([
      for gr in try(sp.permissions, []) : [
        for r in gr.role : {
          role = r == "Manage" ? "roles/servicePrincipal.manager" : "roles/servicePrincipal.user"
          principals = [
            for p in gr.principals :
            p.type == "group" ? "groups/${local.group_name_to_id[p.name]}" :
            p.type == "user" ? "users/${p.name}" :
            "servicePrincipals/${p.name}"
          ]
        }
      ]
    ])
    if length(try(sp.permissions, [])) > 0
  }
}

resource "databricks_access_control_rule_set" "group_permissions" {
  provider = databricks.mws
  for_each = local.group_grant_rules_flat

  name = "accounts/${var.account_id}/groups/${local.group_name_to_id[each.key]}/ruleSets/default"

  dynamic "grant_rules" {
    for_each = each.value
    content {
      role       = grant_rules.value.role
      principals = grant_rules.value.principals
    }
  }
}

resource "databricks_access_control_rule_set" "sp_permissions" {
  provider = databricks.mws
  for_each = local.sp_grant_rules_flat

  name = "accounts/${var.account_id}/servicePrincipals/${databricks_service_principal.this[each.key].application_id}/ruleSets/default"

  dynamic "grant_rules" {
    for_each = each.value
    content {
      role       = grant_rules.value.role
      principals = grant_rules.value.principals
    }
  }
}

output "groups_map" {
  value = merge(
    { for k, v in databricks_group.this : k => { id = v.id, display_name = v.display_name } },
    { for k, v in data.databricks_group.existing : k => { id = v.id, display_name = v.display_name } }
  )
}

output "membership_debug" {
  value = {
    user_memberships_created = length(databricks_group_member.user_membership)
    sp_memberships_created   = length(databricks_group_member.sp_membership)
    user_memberships_dropped = length(local.user_memberships_dropped)
    sp_memberships_dropped   = length(local.sp_memberships_dropped)
  }
  description = "Compact debug counters for account-level group membership reconciliation"
}
