output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.storage_bucket.bucket
}

output "bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = aws_s3_bucket.storage_bucket.arn
}

output "bucket_id" {
  description = "ID of the created S3 bucket"
  value       = aws_s3_bucket.storage_bucket.id
}
