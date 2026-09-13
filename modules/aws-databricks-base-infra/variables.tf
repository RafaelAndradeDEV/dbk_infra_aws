variable "tags" {
  type        = map(string)
  description = "(Required) Map of tags to apply to all created resources"
}

variable "prefix" {
  type        = string
  description = "(Required) Prefix for the resources deployed by this module"
}

variable "cidr_block" {
  type        = string
  description = "(Required) CIDR block for the VPC that will be used to create the Databricks workspace"
}

variable "subnet_block_to_create" {
  type        = number
  description = "(Required) Number of private subnet blocks to create from cidr_block"
  default     = 6
}

variable "private_subnet_prefix_length" {
  type        = number
  description = "(Required) Prefix length for subnets (/17.. /26). Must be >= VPC prefix."
  default     = 24

  validation {
    condition     = var.private_subnet_prefix_length >= 17 && var.private_subnet_prefix_length <= 26
    error_message = "private_subnet_prefix_length must be between 17 and 26."
  }

  validation {
    condition     = var.private_subnet_prefix_length >= tonumber(element(split("/", var.cidr_block), 1))
    error_message = "private_subnet_prefix_length must be greater than or equal to the VPC CIDR prefix."
  }
}

variable "databricks_account_id" {
  type        = string
  description = "(Required) Databricks Account ID"
}

variable "storage_credential_configs" {
  type = map(object({
    name          = string
    bucket_name   = string
    create_bucket = optional(bool, false)
    prefix        = optional(string, "*")
  }))
  description = <<-EOT
    (Optional) Map of Unity Catalog storage credential configs.

    Each item creates one `databricks_storage_credential` and a dedicated IAM role scoped to that bucket/prefix.
    If `create_bucket` is true, the S3 bucket is created via the `./storage_bucket` submodule.
    `prefix` scopes object access to that key prefix inside the bucket (default: "*").
  EOT
  default     = {}
}

variable "aws_region" {
  type        = string
  description = "(Required) AWS region"
}

variable "databricks_uc_master_role_arn" {
  type        = string
  description = "(Optional) Databricks UC master role ARN (override for GovCloud)"
  default     = "arn:aws:iam::414351767826:role/unity-catalog-prod-UCMasterRole-14S5ZJVKOTYTL"
}

variable "metastore_bucket_name" {
  type        = string
  description = "(Required) Metastore bucket name"
}
variable "reuse_metastore" {
  type        = bool
  description = "(Required) Reuse metastore bucket. Skips creating root bucket if true"
  default     = false
}

variable "enable_backend_private_link" {
  type        = bool
  description = "Enable Databricks back-end PrivateLink (creates interface endpoints + Databricks endpoint registrations). Reuses the VPC/subnets from vpc.tf."
  default     = false
}

variable "workspace_endpoint_service" {
  type        = string
  description = "(Optional) Databricks workspace (REST API) VPC endpoint service name (required if enable_backend_private_link = true)"
  default     = null
}

variable "cluster_relay_endpoint_service" {
  type        = string
  description = "(Optional) Databricks cluster connectivity relay VPC endpoint service name (required if enable_backend_private_link = true)"
  default     = null
}

variable "service_direct_endpoint_service" {
  type        = string
  description = "(Optional) Databricks service-direct VPC endpoint service name (optional, covers telemetry and direct service access)"
  default     = null
}

variable "databricks_dataplane_security_group_id" {
  type        = string
  description = "(Optional) Security group ID used by Databricks dataplane. If null, we fall back to the first ID in local.effective_security_group_ids."
  default     = null
}

variable "private_access_public_access_enabled" {
  type        = bool
  description = "When using Private Access Settings, allow public access to the workspace URL. Set to false only if you have front-end PrivateLink/VPN for users and Terraform."
  default     = true
}

variable "extra_pass_role_arns" {
  type        = list(string)
  description = "(Optional) IAM role ARNs the cross-account role may pass (iam:PassRole), e.g. a CI agent role used for custom container images. Empty disables the extra policy."
  default     = []
}
