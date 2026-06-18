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
