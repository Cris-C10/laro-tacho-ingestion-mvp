output "bucket_name" {
  description = "Raw bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "Raw bucket ARN"
  value       = aws_s3_bucket.this.arn
}
