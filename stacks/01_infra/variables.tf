variable "tags" {
  description = "Tags applied to created resources"
  type        = map(string)
  default     = { Project = "Dbk-Project" }
}
variable "databricks_client_id" {
  type        = string
  description = "(Required) Databricks Client ID"
}

variable "databricks_client_secret" {
  type        = string
  description = "(Required) Databricks Client Secret"
}
