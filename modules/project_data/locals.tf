terraform {
  required_version = ">=1.13.1"
}

locals {
  # General project configuration
  _project_config_path = abspath("${path.module}/../../configs/project_configs.yml")
  project_config       = yamldecode(try(file(local._project_config_path), "{}"))
  metastore_config     = local.project_config.metastore_config
  # Workspace configuration
  _workspace_config_path = abspath("${path.module}/../../configs/workspace_configs.yml")
  workspace_config       = yamldecode(try(file(local._workspace_config_path), "{}"))
  # Principal configuration (Users, service principals, groups)
  _principal_config_path = abspath("${path.module}/../../configs/principal_configs.yml")
  principal_config       = yamldecode(try(file(local._principal_config_path), "{}"))

  workspaces_list = try(local.workspace_config.workspaces, [])
  # Normalize workspace entries from YAML and add structured catalogs array.
  # - Supports both string and object entries under `catalogs`.
  # - Ensures catalog names are underscore-safe for Databricks.
  # - Defaults isolation_mode to ISOLATED unless marked is_default (handled later).
  workspaces_normalized = [
    for w in local.workspaces_list : merge(w, {
      catalogs = [
        for c in try(w.catalogs, []) : (
          can(c.name)
          ? {
            name           = replace(c.name, "-", "_")
            isolation_mode = upper(try(c.isolation_mode, "ISOLATED"))
            purpose        = try(c.purpose, "Workspace catalog")
            storage_root   = try(c.storage_root, null)
          }
          : {
            name           = replace(c, "-", "_")
            isolation_mode = "ISOLATED"
            purpose        = "Workspace catalog"
            storage_root   = null
          }
        )
      ]
      schemas = [
        for s in try(w.schemas, []) : {
          name         = replace(s.name, "-", "_")
          catalogs     = [for catalog in try(s.catalogs, []) : replace(catalog, "-", "_")]
          storage_root = try(s.storage_root, null)
        }
      ]
      external_locations = [
        for el in try(w.external_locations, []) : {
          name               = replace(el.name, "-", "_")
          url                = el.url
          credential_name    = el.credential_name
          comment            = try(el.comment, null)
          enable_file_events = try(el.enable_file_events, null)
          file_event_queue   = try(el.file_event_queue, null)
        }
      ]
      federated_catalogs = [
        for fc in try(w.federated_catalogs, []) : {
          name            = replace(fc.name, "-", "_")
          connection_type = fc.connection_type
          comment         = try(fc.comment, null)
          read_only       = try(fc.read_only, false)
          options         = try({ for k, v in fc.options : k => tostring(v) }, {})
          secrets = [
            for s in try(fc.secrets, []) : {
              option_key      = s.option_key
              secret_arn      = s.secret_arn
              secret_json_key = s.secret_json_key
            }
          ]
          catalog_options = try({ for k, v in fc.catalog_options : k => tostring(v) }, {})
        }
      ]
      storage_credential_names = try(w.storage_credential_names, [])
      # Normalize tags to ensure they're valid maps with no empty keys or null values
      # Handle cases where tags might be null, empty, or not a map
      cluster_tags = try(
        {
          for k, v in w.cluster_tags : k => v
          if k != null && k != "" && v != null && v != "" && can(tostring(v))
        },
        {}
      )
      sql_endpoint_tags = try(
        {
          for k, v in w.sql_endpoint_tags : k => v
          if k != null && k != "" && v != null && v != "" && can(tostring(v))
        },
        {}
      )
      all_purpose_clusters = try(w.all_purpose_clusters, [])
      sql_warehouses       = try(w.sql_warehouses, [])
      # Budget configuration with defaults
      budget_amount              = try(w.budget_amount, 0)
      budget_notification_emails = try(w.budget_notification_emails, [])
      # AI Gateway budget
      ai_gateway_budget_amount              = try(w.ai_gateway_budget_amount, 0)
      ai_gateway_budget_notification_emails = try(w.ai_gateway_budget_notification_emails, [])
    })
  ]

  # workspaces_map transforms the normalized list into a map keyed by the workspace name
  workspaces_map  = { for w in local.workspaces_normalized : w.name => w }
  workspace_names = [for w in local.workspaces_list : w.name]

  # General Settings
  project_name          = local.project_config.project_name
  aws_region            = local.project_config.aws_region
  databricks_account_id = try(local.project_config.databricks_account_id, null)

  # Backend state configuration
  backend_state_bucket_name = try(local.project_config.backend_state_bucket_name, "${local.project_name}-tfstate")

  # Default tags
  default_tags = merge({
    Source  = "Terraform"
    Region  = local.aws_region
    Env     = try(local.project_config.env, "dev")
    Project = local.project_name
  }, try(local.project_config.default_tags, {}))

  # Network
  network_cidr_block   = try(local.project_config.network.cidr_block, "10.20.0.0/16")
  public_subnets_cidr  = try(local.project_config.network.public_subnets_cidr, null)
  private_subnets_cidr = try(local.project_config.network.private_subnets_cidr, null)

  # Account
  account_admin_group = local.project_config.account_configs.admin_group

  # Optional Unity Catalog storage credential configs (passed through to aws-databricks-base-infra)
  storage_credential_configs = try(local.project_config.storage_credential_configs, {})

  # PrivateLink
  workspace_endpoint_service      = try(local.project_config.workspace_endpoint_service, null)
  cluster_relay_endpoint_service  = try(local.project_config.cluster_relay_endpoint_service, null)
  service_direct_endpoint_service = try(local.project_config.service_direct_endpoint_service, null)
  enable_backend_private_link     = try(local.project_config.enable_backend_private_link, false)

  # Workspace (single defaults for backward compatibility)
  # TODO: remove this
  workspace_name               = coalesce(try(local.workspace_config.workspace.name, null), try(local.workspaces_list[0].name, null), "project-ws")
  workspace_service_principals = coalesce(try(local.workspace_config.workspace.service_principals, null), try(local.workspaces_list[0].service_principals, null), [])
  workspace_groups             = coalesce(try(local.workspace_config.workspace.groups, null), try(local.workspaces_list[0].groups, null), [])
  default_catalog              = try(local.workspace_config.default_catalog, "default")

  # Account-level principals sourced from principal_configs.yml
  _account_principals = try(local.principal_config.account_principals, {})

  # Normalize users to expected shape for account-principals-managed module
  account_users = [
    for u in try(local._account_principals.users, []) : {
      name                 = try(u.name, null)
      email                = u.email
      allow_cluster_create = try(u.allow_cluster_create, false)
      groups               = try(u.groups, [])
    }
  ]

  # Normalize service principals
  account_service_principals = [
    for sp in try(local._account_principals.service_principals, []) : {
      name         = sp.name
      display_name = try(sp.display_name, null)
      groups       = try(sp.groups, [])
      permissions  = try(sp.permissions, [])
    }
  ]

  # Normalize groups (account-level). Workspace assignments moved to workspace_configs.yml
  account_groups = [
    for g in try(local._account_principals.groups, []) : {
      group_name  = g.name
      skip_create = try(g.skip_create, false)
      permissions = try(g.permissions, [])
    }
  ]

  # Workspace-scoped group assignments built from workspace_configs.yml
  # Shape matches modules/databricks-workspace-setup expectations per workspace
  workspace_account_groups = {
    for w in local.workspaces_list : w.name => [
      for g in try(w.groups, []) : {
        group_name                    = g.name
        workspaces                    = [w.name]
        workspace_permissions         = { (w.name) = try(g.assignments.workspace_permissions, ["USER"]) }
        catalog_privileges            = try(g.assignments.catalog_privileges, [])
        schema_privileges             = try(g.assignments.schema_privileges, [])
        external_location_privileges  = try(g.assignments.external_location_privileges, [])
        storage_credential_privileges = try(g.assignments.storage_credential_privileges, [])
        cluster_privileges            = try(g.assignments.cluster_privileges, [])
        sql_warehouse_privileges      = try(g.assignments.sql_warehouse_privileges, [])
      }
    ]
  }

  # Build a map of workspace name -> list of group names assigned to that workspace
  workspace_group_names = {
    for w in local.workspaces_list : w.name => [for g in try(w.groups, []) : g.name]
  }

  # Workspace-scoped users: filter users by group membership
  # A user is included in a workspace if any of their groups are assigned to that workspace
  workspace_users = {
    for w in local.workspaces_list : w.name => [
      for u in local.account_users : {
        name                 = u.name
        email                = u.email
        allow_cluster_create = u.allow_cluster_create
        groups               = u.groups
      }
      if length(setintersection(toset(u.groups), toset(local.workspace_group_names[w.name]))) > 0
    ]
  }
}
