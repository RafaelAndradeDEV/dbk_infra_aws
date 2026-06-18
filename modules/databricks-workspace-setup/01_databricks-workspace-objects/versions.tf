terraform {
  required_version = ">= 1.13.1"
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 6.14.1"
      configuration_aliases = [aws]
    }
    databricks = {
      source                = "databricks/databricks"
      version               = ">= 1.90.0"
      configuration_aliases = [databricks.workspace]
    }
  }
}
