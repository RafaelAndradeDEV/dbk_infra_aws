variable "databricks_client_id" {
  type        = string
  description = "(Required) Databricks Client ID"
}

variable "databricks_client_secret" {
  type        = string
  description = "(Required) Databricks Client Secret"
}

variable "databricks_uc_master_role_arn" {
  type        = string
  description = "(Optional) Databricks UC master role ARN (default: commercial AWS)."
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}

variable "existing_metastore_id" {
  type        = string
  description = "(Optional) ID of an existing Unity Catalog metastore to attach to. Required when metastore_config.reuse_metastore is true in configs/project_configs.yml."
  default     = null
}
