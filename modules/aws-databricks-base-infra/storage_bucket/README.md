# Storage Bucket Module

This module creates an S3 bucket configured for use with Databricks, including:
- Public access blocking
- Databricks-specific bucket policy
- Versioning configuration
- Optional Databricks storage configuration

## Usage

```
module "storage_bucket" {
  source = "./storage_bucket"

  bucket_name            = "my-databricks-storage-bucket"
  databricks_account_id  = "12345678-1234-1234-1234-123456789012"

  tags = {
    Environment = "production"
    Team        = "data"
  }

  # Enable Databricks access (includes metastore protection)
  enable_databricks_account_access = true

  # Optional: Grant access to specific IAM roles
  allowed_role_arns = [
    "arn:aws:iam::123456789012:role/my-data-processing-role"
  ]
}
```

## Multiple Buckets Example

```
module "analytics_bucket" {
  source = "./storage_bucket"

  bucket_name                      = "${var.prefix}-analytics-bucket"
  enable_databricks_account_access = true
  databricks_account_id            = var.databricks_account_id
  tags                             = var.tags
}

module "ml_bucket" {
  source = "./storage_bucket"

  bucket_name       = "${var.prefix}-ml-bucket"
  tags              = var.tags
  allowed_role_arns = [aws_iam_role.ml_processing.arn]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket_name | Name of the S3 bucket to create | `string` | n/a | yes |
| enable_databricks_account_access | Whether to enable Databricks account access to the bucket (includes both grant and metastore deny policies) | `bool` | `false` | no |
| databricks_account_id | Databricks account ID for bucket policy (required if enable_databricks_account_access is true) | `string` | `""` | no |
| tags | Tags to apply to the S3 bucket | `map(string)` | `{}` | no |
| allowed_role_arns | List of IAM role ARNs that should have access to the bucket | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | Name of the created S3 bucket |
| bucket_arn | ARN of the created S3 bucket |
| bucket_id | ID of the created S3 bucket |
