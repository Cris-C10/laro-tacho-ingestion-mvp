locals {
  project = "laro-tacho"
  env     = "dev"
}

module "raw_store" {
  source = "../../modules/raw_store"

  name = "${local.project}-${local.env}-raw"

  force_destroy = true

  tags = {
    Project = local.project
    Env     = local.env
  }
}

module "ingestion_ledger" {
  source = "../../modules/ingestion_ledger"

  name = "${local.project}-${local.env}-ledger"

  tags = {
    Project = local.project
    Env     = local.env
  }
}

output "raw_bucket_name" {
  value = module.raw_store.bucket_name
}

output "raw_bucket_arn" {
  value = module.raw_store.bucket_arn
}

output "ledger_table_name" {
  value = module.ingestion_ledger.table_name
}

output "ledger_table_arn" {
  value = module.ingestion_ledger.table_arn
}

# ------------------------------------------------------------
# Ingest Lambda Module
# ------------------------------------------------------------
# This module creates:
# - Lambda function
# - IAM role
# - Logging permissions
#
# It connects to:
# - Raw S3 bucket
# - DynamoDB ingestion ledger
#
# No event trigger yet (wired later).
# ------------------------------------------------------------

module "ingest_lambda" {
  source = "../../modules/ingest_lambda"

  lambda_name       = "${local.project}-${local.env}-ingest"
  ledger_table_name = module.ingestion_ledger.table_name
  raw_bucket_name   = module.raw_store.bucket_name
}

# Allow S3 to invoke the ingest Lambda
resource "aws_lambda_permission" "allow_s3_invoke_ingest" {
  statement_id  = "AllowExecutionFromS3RawBucket"
  action        = "lambda:InvokeFunction"
  function_name = module.ingest_lambda.lambda_name
  principal     = "s3.amazonaws.com"
  source_arn    = module.raw_store.bucket_arn
}

# S3 -> Lambda trigger (fires on new uploads)
resource "aws_s3_bucket_notification" "raw_to_ingest" {
  bucket = module.raw_store.bucket_name

  lambda_function {
    lambda_function_arn = module.ingest_lambda.lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3_invoke_ingest]
}