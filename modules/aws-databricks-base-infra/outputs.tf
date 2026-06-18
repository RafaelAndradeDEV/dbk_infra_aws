output "security_group_ids" {
  value       = [module.vpc.default_security_group_id]
  description = "Security group ID for DB Compliant VPC"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnets
  description = "private subnets for workspace creation"
}

output "vpc_main_route_table_id" {
  value       = module.vpc.vpc_main_route_table_id
  description = "ID for the main route table associated with this VPC"
}

output "private_route_table_ids" {
  value       = module.vpc.private_route_table_ids
  description = "IDs for the private route tables associated with this VPC"
}

output "vpc_endpoint_ids" {
  value = var.enable_backend_private_link ? {
    relay     = try(module.vpc_endpoints[0].endpoints["databricks_relay"].id, null)
    workspace = try(module.vpc_endpoints[0].endpoints["databricks_workspace"].id, null)
  } : {}
  description = "Interface VPC endpoint IDs for Databricks PrivateLink (if enabled)"
}

output "databricks_vpc_endpoint_ids" {
  value = var.enable_backend_private_link ? {
    # These are Databricks *MWS* VPC endpoint IDs (not AWS VPC endpoint IDs).
    # They are what `databricks_mws_networks.vpc_endpoints` expects.
    dataplane_relay = [databricks_mws_vpc_endpoint.relay[0].vpc_endpoint_id]
    rest_api        = [databricks_mws_vpc_endpoint.workspace[0].vpc_endpoint_id]
  } : null
  description = "Databricks MWS VPC endpoint IDs for back-end PrivateLink (null when disabled)"
}

output "private_access_settings_id" {
  value       = var.enable_backend_private_link ? databricks_mws_private_access_settings.this[0].private_access_settings_id : null
  description = "Databricks Private Access Settings ID required for PrivateLink workspaces (null when disabled)"
}

output "root_bucket" {
  value       = local.root_bucket_name
  description = "root bucket"
}

output "cross_account_role_arn" {
  value       = aws_iam_role.cross_account_role.arn
  description = "AWS Cross account role arn"
}

output "databricks_credentials_id" {
  value       = databricks_mws_credentials.this.credentials_id
  description = "Databricks MWS credentials ID"
}

output "databricks_storage_configuration_id" {
  value       = databricks_mws_storage_configurations.this.storage_configuration_id
  description = "Databricks MWS storage configuration ID"
}

output "aws_extra_security_group" {
  value       = aws_security_group.extra_sg.id
  description = "AWS extra security group ID"
}

output "storage_configuration_role_arn" {
  value       = aws_iam_role.unity_catalog_main_role.arn
  description = "IAM role ARN for storage configuration"
}

output "storage_data_access_role_names" {
  value       = { for k, r in aws_iam_role.storage_data_access : k => r.name }
  description = "Map of IAM role names for UC storage credentials (keyed by storage_credential_configs key)"
}

output "storage_data_access_role_arns" {
  value       = { for k, r in aws_iam_role.storage_data_access : k => r.arn }
  description = "Map of IAM role ARNs for UC storage credentials (keyed by storage_credential_configs key)"
}

output "storage_credential_configs" {
  value       = var.storage_credential_configs
  description = "Pass-through: storage credential configs used to create AWS-side resources in this module"
}

output "storage_buckets" {
  value = {
    for k, v in var.storage_credential_configs : k => {
      bucket_name   = v.bucket_name
      bucket_arn    = try(local.bucket_arn_by_key[k], null)
      create_bucket = try(v.create_bucket, false)
      prefix        = try(v.prefix, "*")
      object_arn    = try(local.object_arn_by_key[k], null)
    }
  }
  description = "Per-storage-credential bucket details (created or referenced) keyed by config key"
}
