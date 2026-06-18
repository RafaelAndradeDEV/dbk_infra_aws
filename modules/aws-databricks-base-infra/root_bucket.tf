resource "aws_s3_bucket" "root_storage_bucket" {
  count  = var.reuse_metastore ? 0 : 1
  bucket = var.metastore_bucket_name
  tags = merge(var.tags, {
    Name = var.metastore_bucket_name
  })
}

data "aws_s3_bucket" "existing_bucket" {
  count  = var.reuse_metastore ? 1 : 0
  bucket = var.metastore_bucket_name
}

locals {
  root_bucket_name = var.reuse_metastore ? data.aws_s3_bucket.existing_bucket[0].bucket : aws_s3_bucket.root_storage_bucket[0].bucket
  root_bucket_arn  = var.reuse_metastore ? data.aws_s3_bucket.existing_bucket[0].arn : aws_s3_bucket.root_storage_bucket[0].arn
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = local.root_bucket_name

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "root_storage_bucket" {
  bucket                  = local.root_bucket_name
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [local.root_bucket_name]
}

data "aws_iam_policy_document" "bucket_policy" {
  # HIPAA: deny any non-TLS (HTTP) access
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      local.root_bucket_arn,
      "${local.root_bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    sid    = "Grant Databricks Access"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      local.root_bucket_arn,
      "${local.root_bucket_arn}/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalTag/DatabricksAccountId"
      values   = [var.databricks_account_id]
    }
  }

  statement {
    sid    = "Prevent DBFS from accessing Unity Catalog metastore"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::414351767826:root"]
    }
    actions   = ["s3:*"]
    resources = ["${local.root_bucket_arn}/metastore/*"]
  }
}

resource "aws_s3_bucket_policy" "root_bucket_policy" {
  bucket     = local.root_bucket_name
  policy     = data.aws_iam_policy_document.bucket_policy.json
  depends_on = [local.root_bucket_name]
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = local.root_bucket_name
  versioning_configuration {
    status = "Suspended"
  }
}

resource "databricks_mws_storage_configurations" "this" {
  account_id                 = var.databricks_account_id
  bucket_name                = local.root_bucket_name
  storage_configuration_name = "${var.prefix}-storage-v2"
}
