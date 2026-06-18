variable "users" {
  type = list(object({
    name                 = optional(string)
    email                = string
    allow_cluster_create = optional(bool)
    groups               = optional(list(string))
  }))
  default = []
}
variable "account_id" {
  type        = string
  description = "Databricks account ID, used to construct access control rule set names for service principals."
  validation {
    condition     = can(regex("^[a-f0-9-]+$", var.account_id))
    error_message = "account_id must be a valid UUID format."
  }
}

variable "service_principals" {
  type = list(object({
    name         = string
    display_name = optional(string)
    groups       = optional(list(string))
    permissions = optional(list(object({
      role       = list(string)
      principals = list(object({ type = string, name = string }))
    })))
  }))
  default = []
  validation {
    condition = alltrue([
      for sp in var.service_principals : alltrue([
        for perm in try(sp.permissions, []) : alltrue([
          for r in perm.role : contains(["Manage", "Use"], r)
        ])
      ])
    ])
    error_message = "Service principal permission role must be either 'Manage' or 'Use'."
  }
}
variable "groups" {
  type = list(object({
    group_name            = string
    skip_create           = optional(bool)
    workspaces            = optional(list(string))
    workspace_permissions = optional(map(list(string)))
    catalog_privileges    = optional(list(object({ catalog_name = string, privileges = list(string) })))
    cluster_privileges    = optional(list(object({ cluster_name = string, privileges = list(string) })))
    permissions = optional(list(object({
      role       = list(string)
      principals = list(object({ type = string, name = string }))
    })))
  }))
  default = []
}
