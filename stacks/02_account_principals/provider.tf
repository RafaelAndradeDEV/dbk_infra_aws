terraform {
  required_version = ">=1.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.14.1"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">= 1.90.0"
    }
  }
  backend "s3" {
    bucket = "project-dbk-infra-east-tfstate"
    key    = "account_principals/terraform.tfstate"
    region = "us-east-2"
  }
}

module "project_data" {
  source = "../../modules/project_data"
}

provider "aws" {
  region = module.project_data.aws_region
  default_tags {
    tags = {
      ManagedBy = "Rafael-Team"
      Owner     = "Rafael.Andrade"
      Project   = "Dbk-Project"
      Region    = "us-east-2"
      Source    = "Terraform"
    }
  }
}

# Databricks account provider for UC resources
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = module.project_data.databricks_account_id
  client_id     = var.databricks_client_id
  client_secret = var.databricks_client_secret
}
