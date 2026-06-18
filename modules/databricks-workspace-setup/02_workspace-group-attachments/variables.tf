variable "workspace_name" { type = string }
variable "account_groups" {
  type = list(object({
    group_name                    = string
    workspaces                    = list(string)
    workspace_permissions         = optional(map(list(string)))
    catalog_privileges            = optional(list(object({ catalog_name = string, privileges = list(string) })))
    schema_privileges             = optional(list(object({ catalog_name = string, schema_name = string, privileges = list(string) })))
    external_location_privileges  = optional(list(object({ external_location_name = string, privileges = list(string) })))
    storage_credential_privileges = optional(list(object({ storage_credential_name = string, privileges = list(string) })))
    cluster_privileges            = optional(list(object({ cluster_name = string, privileges = list(string) })))
    sql_warehouse_privileges      = optional(list(object({ warehouse_name = string, privileges = list(string) })))
  }))
}
variable "group_principal_ids" { type = map(object({ id = string, display_name = string })) }
variable "cluster_ids" { type = map(string) }
variable "sql_warehouse_ids" { type = map(string) }
variable "apply_catalog_grants" {
  type    = bool
  default = true
}

variable "bound_storage_credential_names" {
  description = "List of storage credential names that are bound to the workspace."
  type        = list(string)
  default     = []
}
