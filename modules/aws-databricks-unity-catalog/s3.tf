# Assumes an already existing S3 bucket
data "aws_s3_bucket" "metastore" {
  bucket = var.metastore_bucket
}
