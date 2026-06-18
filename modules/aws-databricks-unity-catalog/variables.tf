# variable "tags" {
#   default     = {}
#   type        = map(string)
#   description = "(Optional) List of tags to be propagated across all assets in this demo"
# }

variable "prefix" {
  type        = string
  description = "(Required) Prefix to name the resources created by this module"
}

variable "metastore_region" {
  type        = string
  description = "(Required) AWS region for the Unity Catalog metastore"
}

variable "metastore_owner" {
  description = "(Required) Name of the principal that will be the owner of the Metastore"
  type        = string
}

variable "metastore_name" {
  description = "(Optional) Name of the metastore that will be created"
  type        = string
  default     = null
}

locals {
  metastore_name = var.metastore_name == null ? "${var.prefix}-metastore" : var.metastore_name
}


variable "metastore_bucket" {
  description = "Existing S3 bucket name to use for UC metastore (no s3:// prefix)"
  type        = string
}


variable "storage_configuration_role_arn" {
  description = "IAM role ARN for storage configuration"
  type        = string
}

variable "reuse_metastore" {
  description = "If true, looks up the existing metastore by ID instead of creating a new one"
  type        = bool
  default     = false
}

variable "existing_metastore_id" {
  description = "ID of the existing metastore to reuse (required when reuse_metastore = true)"
  type        = string
  default     = null
}
