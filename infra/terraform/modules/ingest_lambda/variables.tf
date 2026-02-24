# ------------------------------------------------------------
# Module Variables
# ------------------------------------------------------------

# Name of the Lambda function
variable "lambda_name" {
  description = "Name of the ingest Lambda function"
  type        = string
}

# DynamoDB table name (ledger)
variable "ledger_table_name" {
  description = "Name of the DynamoDB ledger table"
  type        = string
}

# S3 raw bucket name
variable "raw_bucket_name" {
  description = "Name of the raw S3 bucket"
  type        = string
}