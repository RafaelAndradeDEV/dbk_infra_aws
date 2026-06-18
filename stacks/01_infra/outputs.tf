output "vpc_id" {
  value       = module.aws_base.vpc_id
  description = "VPC ID"
}

output "security_group_ids" {
  value       = module.aws_base.security_group_ids
  description = "Security group IDs for the workspace"
}

output "private_subnet_ids" {
  value       = module.aws_base.private_subnet_ids
  description = "Private subnets for the workspace"
}

output "root_bucket" {
  value       = module.aws_base.root_bucket
  description = "Root storage bucket for the workspace"
}

output "cross_account_role_arn" {
  value       = module.aws_base.cross_account_role_arn
  description = "Cross account role ARN"
}

output "databricks_credentials_id" {
  value       = module.aws_base.databricks_credentials_id
  description = "Databricks MWS credentials ID"
}

output "databricks_storage_configuration_id" {
  value       = module.aws_base.databricks_storage_configuration_id
  description = "Databricks MWS storage configuration ID"
}

output "aws_extra_security_group" {
  value       = module.aws_base.aws_extra_security_group
  description = "AWS extra security group ID"
}

output "storage_configuration_role_arn" {
  value       = module.aws_base.storage_configuration_role_arn
  description = "IAM role ARN for storage configuration"
}

output "storage_data_access_role_names" {
  value       = module.aws_base.storage_data_access_role_names
  description = "Map of IAM role names for UC storage credentials (for use by later stacks)"
}

output "storage_data_access_role_arns" {
  value       = module.aws_base.storage_data_access_role_arns
  description = "Map of IAM role ARNs for UC storage credentials (for use by later stacks)"
}

output "storage_credential_configs" {
  value       = module.aws_base.storage_credential_configs
  description = "Pass-through: storage credential configs (for use by later stacks)"
}

output "storage_buckets" {
  value       = module.aws_base.storage_buckets
  description = "Per-storage-credential bucket details (for use by later stacks)"
}
