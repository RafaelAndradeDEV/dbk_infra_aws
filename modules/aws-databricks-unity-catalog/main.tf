data "databricks_metastore" "existing" {
  count        = var.reuse_metastore ? 1 : 0
  metastore_id = var.existing_metastore_id
}

resource "databricks_metastore" "this" {
  count        = var.reuse_metastore ? 0 : 1
  name         = local.metastore_name
  region       = var.metastore_region
  owner        = var.metastore_owner
  storage_root = "s3://${data.aws_s3_bucket.metastore.id}/metastore"
  # force_destroy = true
}

locals {
  metastore_id = var.reuse_metastore ? data.databricks_metastore.existing[0].id : databricks_metastore.this[0].id
}

resource "databricks_metastore_data_access" "this" {
  metastore_id = local.metastore_id
  name         = "${var.prefix}-metastore-data-access"
  aws_iam_role {
    role_arn = var.storage_configuration_role_arn
  }
  is_default = true
}
