terraform {
  required_version = ">= 1.13.1"
  required_providers {
    databricks = {
      source                = "databricks/databricks"
      version               = ">= 1.90.0"
      configuration_aliases = [databricks.mws]
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
  }
}
