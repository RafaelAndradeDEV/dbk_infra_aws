module "project_data" {
  source = "../../modules/project_data"
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = module.project_data.backend_state_bucket_name
    key    = "infra/terraform.tfstate"
    region = module.project_data.aws_region
  }
}

module "unity_catalog" {
  source = "../../modules/aws-databricks-unity-catalog"
  providers = {
    databricks = databricks.mws
  }
  metastore_name                 = module.project_data.metastore_config.metastore_name
  prefix                         = module.project_data.project_name
  metastore_region               = module.project_data.aws_region
  metastore_owner                = module.project_data.account_admin_group
  metastore_bucket               = module.project_data.metastore_config.metastore_bucket_name
  storage_configuration_role_arn = data.terraform_remote_state.infra.outputs.storage_configuration_role_arn
  reuse_metastore                = module.project_data.metastore_config.reuse_metastore
  existing_metastore_id          = module.project_data.metastore_config.reuse_metastore ? "0c498fbf-e3bf-4ea1-b25a-5277da23afc7" : null
}

output "metastore_id" {
  value       = module.unity_catalog.metastore_id
  description = "Unity Catalog metastore ID"
}
