# ------------------------------------------------------------
# Outputs
# ------------------------------------------------------------

# Lambda function name
output "lambda_name" {
  description = "Name of the ingest Lambda"
  value       = aws_lambda_function.ingest.function_name
}

# Lambda ARN
output "lambda_arn" {
  description = "ARN of the ingest Lambda"
  value       = aws_lambda_function.ingest.arn
}

# IAM Role ARN
output "lambda_role_arn" {
  description = "IAM role ARN used by Lambda"
  value       = aws_iam_role.lambda_role.arn
}