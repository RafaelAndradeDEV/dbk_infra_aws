# Assign metastore to workspace
resource "databricks_metastore_assignment" "this" {
  provider     = databricks.workspace
  metastore_id = var.metastore_id
  workspace_id = var.workspace_id
}

# Create workspace external locations - needed for catalogs
resource "databricks_workspace_binding" "storage_credentials" {
  provider = databricks.workspace
  for_each = toset(var.storage_credential_names)

  workspace_id   = var.workspace_id
  securable_type = "storage_credential"
  securable_name = each.value
  depends_on     = [databricks_metastore_assignment.this]
}

resource "databricks_external_location" "external_locations" {
  provider = databricks.workspace
  for_each = { for el in var.external_locations : el.name => el }

  name               = each.value.name
  url                = each.value.url
  credential_name    = each.value.credential_name
  comment            = try(each.value.comment, null)
  enable_file_events = try(each.value.enable_file_events, null)

  dynamic "file_event_queue" {
    for_each = try(each.value.file_event_queue, null) != null ? [each.value.file_event_queue] : []
    content {
      dynamic "managed_sqs" {
        for_each = try(file_event_queue.value.managed_sqs, null) != null ? [file_event_queue.value.managed_sqs] : []
        content {}
      }

      dynamic "provided_sqs" {
        for_each = try(file_event_queue.value.provided_sqs, null) != null ? [file_event_queue.value.provided_sqs] : []
        content {
          queue_url = provided_sqs.value.queue_url
        }
      }
    }
  }

  depends_on = [
    databricks_workspace_binding.storage_credentials
  ]
}


# Create workspace objects: catalogs, cluster, etc.
module "databricks_workspace_configuration" {
  source = "./01_databricks-workspace-objects"
  providers = {
    aws                  = aws
    databricks.workspace = databricks.workspace
  }

  admin_group_principal_id = var.admin_group_principal_id
  cluster_tags             = var.cluster_tags
  sql_endpoint_tags        = var.sql_endpoint_tags
  default_sql_wh_name      = var.default_sql_wh_name
  sql_warehouses           = var.sql_warehouses
  catalogs                 = var.catalogs
  schemas                  = var.schemas
  dev_schema_catalog_name  = var.dev_schema_catalog_name
  users                    = var.users
  all_purpose_clusters     = var.all_purpose_clusters
  federated_catalogs       = var.federated_catalogs
  depends_on = [
    databricks_external_location.external_locations,
    databricks_metastore_assignment.this
  ]
}

# Create workspace group attachments: add groups to workspace, assign cluster privileges, etc.
locals {
  groups_for_workspace = { for g in var.account_groups : g.group_name => g if contains(g.workspaces, var.workspace_name) }
}

data "databricks_group" "ws_groups" {
  provider     = databricks.mws
  for_each     = local.groups_for_workspace
  display_name = each.value.group_name
}

locals {
  group_principal_ids = { for k, v in data.databricks_group.ws_groups : v.display_name => { id = v.id, display_name = v.display_name } }
}



module "workspace_group_attachments" {
  source = "./02_workspace-group-attachments"
  providers = {
    databricks.workspace = databricks.workspace
  }
  depends_on = [
    databricks_workspace_binding.storage_credentials,
    databricks_external_location.external_locations,
    module.databricks_workspace_configuration
  ]
  workspace_name                 = var.workspace_name
  account_groups                 = values(local.groups_for_workspace)
  group_principal_ids            = local.group_principal_ids
  cluster_ids                    = module.databricks_workspace_configuration.cluster_id
  apply_catalog_grants           = true
  sql_warehouse_ids              = module.databricks_workspace_configuration.sql_endpoint_ids_and_names
  bound_storage_credential_names = [for k, v in databricks_workspace_binding.storage_credentials : v.securable_name]
}

resource "databricks_budget" "ai_gateway" {
  count        = var.ai_gateway_budget_amount > 0 ? 1 : 0
  provider     = databricks.mws
  display_name = "${var.workspace_name}-ai-gateway-budget"

  alert_configurations {
    time_period        = "MONTH"
    trigger_type       = "CUMULATIVE_SPENDING_EXCEEDED"
    quantity_type      = "LIST_PRICE_DOLLARS_USD"
    quantity_threshold = tostring(var.ai_gateway_budget_amount)

    dynamic "action_configurations" {
      for_each = var.ai_gateway_budget_notification_emails
      content {
        action_type = "EMAIL_NOTIFICATION"
        target      = action_configurations.value
      }
    }
  }

  filter {
    workspace_id {
      operator = "IN"
      values   = [var.workspace_id]
    }
    tags {
      key = "ai_gateway"
      value {
        operator = "IN"
        values   = ["true"]
      }
    }
  }
}

resource "databricks_budget" "this" {
  count        = var.budget_amount > 0 ? 1 : 0
  provider     = databricks.mws
  display_name = "${var.workspace_name}-budget-definition"

  alert_configurations {
    time_period        = "MONTH"
    trigger_type       = "CUMULATIVE_SPENDING_EXCEEDED"
    quantity_type      = "LIST_PRICE_DOLLARS_USD"
    quantity_threshold = tostring(var.budget_amount)

    dynamic "action_configurations" {
      for_each = var.budget_notification_emails
      content {
        action_type = "EMAIL_NOTIFICATION"
        target      = action_configurations.value
      }
    }
  }

  filter {
    workspace_id {
      operator = "IN"
      values   = [var.workspace_id]
    }

    dynamic "tags" {
      for_each = var.budget_tag_filter
      content {
        key = tags.key
        value {
          operator = "IN"
          values   = tags.value
        }
      }
    }
  }
}
