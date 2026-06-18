
module "project_data" {
  source = "../../modules/project_data"
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = module.project_data.backend_state_bucket_name
    key    = "infra/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "metastore" {
  backend = "s3"
  config = {
    bucket = module.project_data.backend_state_bucket_name
    key    = "uc/terraform.tfstate"
    region = "us-east-2"
  }
}

data "databricks_group" "account_admin_group" {
  provider     = databricks.mws
  display_name = module.project_data.account_admin_group
}
