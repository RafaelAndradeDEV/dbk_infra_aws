module "project_data" {
  source = "../../modules/project_data"
}
module "aws_base" {
  providers = {
    databricks = databricks.mws,
    time       = time
  }
  aws_region                   = module.project_data.aws_region
  source                       = "../../modules/aws-databricks-base-infra"
  prefix                       = module.project_data.project_name
  databricks_account_id        = module.project_data.databricks_account_id
  cidr_block                   = module.project_data.network_cidr_block
  tags                         = var.tags
  metastore_bucket_name        = module.project_data.metastore_config.metastore_bucket_name
  reuse_metastore              = module.project_data.metastore_config.reuse_metastore
  private_subnet_prefix_length = 24
  subnet_block_to_create       = 10

  storage_credential_configs = module.project_data.storage_credential_configs

  # Back-end PrivateLink (explicitly enabled in configs/project_configs.yml)
  enable_backend_private_link     = local.enable_backend_private_link
  workspace_endpoint_service      = module.project_data.workspace_endpoint_service
  cluster_relay_endpoint_service  = module.project_data.cluster_relay_endpoint_service
  service_direct_endpoint_service = module.project_data.service_direct_endpoint_service
}
