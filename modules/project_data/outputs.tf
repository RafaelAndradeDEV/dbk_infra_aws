output "project_name" {
  value       = local.project_name
  description = "Project name"
}

output "aws_region" {
  value       = local.aws_region
  description = "AWS region"
}

output "backend_state_bucket_name" {
  value       = local.backend_state_bucket_name
  description = "S3 bucket name for Terraform remote state"
}

output "default_tags" {
  value       = local.default_tags
  description = "Default tags for resources"
}

# Extended outputs for centralized config
output "network_cidr_block" {
  value       = local.network_cidr_block
  description = "VPC CIDR block"
}

output "public_subnets_cidr" {
  value       = local.public_subnets_cidr
  description = "Public subnets CIDR list"
}

output "private_subnets_cidr" {
  value       = local.private_subnets_cidr
  description = "Private subnets CIDR list"
}

output "databricks_account_id" {
  value       = local.databricks_account_id
  description = "Databricks Account ID"
}

output "workspace_name" {
  value       = local.workspace_name
  description = "Databricks workspace name"
}

output "workspace_users" {
  value       = local.workspace_users
  description = "Databricks workspace users"
}

output "workspace_service_principals" {
  value       = local.workspace_service_principals
  description = "Databricks workspace service principals"
}

output "workspace_groups" {
  value       = local.workspace_groups
  description = "Databricks workspace groups"
}

output "account_admin_group" {
  value       = local.account_admin_group
  description = "Unity Catalog admin group name"
}

# References: https://docs.databricks.com/aws/en/resources/ip-domain-region#privatelink-vpc-endpoint-services
output "workspace_endpoint_service" {
  value       = local.workspace_endpoint_service
  description = "Workspace endpoint endpoint service from Databricks"
}

output "cluster_relay_endpoint_service" {
  value       = local.cluster_relay_endpoint_service
  description = "Cluster connectivity relay endpoint service from Databricks"
}

output "service_direct_endpoint_service" {
  value       = local.service_direct_endpoint_service
  description = "Service-direct endpoint service from Databricks (covers telemetry and direct service access)"
}

output "enable_backend_private_link" {
  value       = local.enable_backend_private_link
  description = "Whether to enable Databricks back-end PrivateLink in the VPC module"
}

output "default_catalog" {
  value       = local.default_catalog
  description = "Default catalog"
}

output "workspaces" {
  value       = local.workspaces_map
  description = "Map of workspaces keyed by name"
}

output "workspace_names" {
  value       = local.workspace_names
  description = "List of workspace names"
}

output "account_users" {
  value       = local.account_users
  description = "Account-level users"
}

output "account_service_principals" {
  value       = local.account_service_principals
  description = "Account-level service principals"
}

output "account_groups" {
  value       = local.account_groups
  description = "Account-level groups with workspaces scoping"
}

output "workspace_account_groups" {
  value       = local.workspace_account_groups
  description = "Per-workspace list of group assignments derived from workspace_configs.yml"
}

output "metastore_config" {
  value       = local.metastore_config
  description = "Metastore configuration"
}

output "storage_credential_configs" {
  value       = local.storage_credential_configs
  description = "Optional map of Unity Catalog storage credential configs (from project_configs.yml)"
}
