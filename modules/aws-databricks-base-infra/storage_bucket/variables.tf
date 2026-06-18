variable "bucket_name" {
  description = "Name of the S3 bucket to create"
  type        = string
}

# The databricks account id should not change, so we can just use the default value
variable "databricks_account_id" {
  description = "Databricks account ID for bucket policy (required if enable_databricks_account_access is true)"
  type        = string
  default     = "414351767826"
}

variable "tags" {
  description = "Tags to apply to the S3 bucket"
  type        = map(string)
  default     = {}
}

variable "enable_databricks_account_access" {
  description = "Whether to enable Databricks account access to the bucket (includes both grant and metastore deny policies)"
  type        = bool
  default     = false
}

variable "allowed_role_arns" {
  description = "List of IAM role ARNs that should have access to the bucket"
  type        = list(string)
  default     = []
}
