resource "aws_s3_bucket" "storage_bucket" {
  bucket        = var.bucket_name
  force_destroy = true
  tags = merge(var.tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage_bucket" {
  bucket = aws_s3_bucket.storage_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "storage_bucket" {
  bucket                  = aws_s3_bucket.storage_bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.storage_bucket]
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
      aws_s3_bucket.storage_bucket.arn,
      "${aws_s3_bucket.storage_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_databricks_account_access ? [1] : []
    content {
      sid    = "Grant Databricks Access"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${var.databricks_account_id}:root"]
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
        aws_s3_bucket.storage_bucket.arn,
        "${aws_s3_bucket.storage_bucket.arn}/*"
      ]
      condition {
        test     = "StringEquals"
        variable = "aws:PrincipalTag/DatabricksAccountId"
        values   = [var.databricks_account_id]
      }
    }
  }

  dynamic "statement" {
    for_each = length(var.allowed_role_arns) > 0 ? [1] : []
    content {
      sid    = "Grant Role Access"
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.allowed_role_arns
      }
      actions = [
        # Read
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetObjectAcl",
        "s3:GetObjectTagging",
        "s3:ListBucket",
        "s3:GetBucketLocation",

        # Write/Delete (Databricks external location validation expects these)
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectTagging",
        "s3:DeleteObject",
        "s3:DeleteObjectTagging",

        # Multipart uploads
        "s3:AbortMultipartUpload",
        "s3:ListMultipartUploadParts",
        "s3:ListBucketMultipartUploads"
      ]
      resources = [
        aws_s3_bucket.storage_bucket.arn,
        "${aws_s3_bucket.storage_bucket.arn}/*"
      ]
    }
  }

  dynamic "statement" {
    for_each = var.enable_databricks_account_access ? [1] : []
    content {
      sid    = "Prevent DBFS from accessing Unity Catalog metastore"
      effect = "Deny"
      principals {
        type        = "AWS"
        identifiers = ["arn:aws:iam::${var.databricks_account_id}:root"]
      }
      actions   = ["s3:*"]
      resources = ["${aws_s3_bucket.storage_bucket.arn}/*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket     = aws_s3_bucket.storage_bucket.bucket
  policy     = data.aws_iam_policy_document.bucket_policy.json
  depends_on = [aws_s3_bucket.storage_bucket]
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.storage_bucket.bucket
  versioning_configuration {
    status = "Suspended"
  }
}
