# ------------------------------------------------------------
# Terraform Provider Requirements
# ------------------------------------------------------------
# We explicitly declare required providers and versions.
# This ensures reproducibility and prevents silent version drift.

terraform {
  required_providers {

    # AWS provider for infrastructure resources
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    # Archive provider allows us to zip the Lambda source code
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
  }
}

# ------------------------------------------------------------
# Package Lambda Source Code
# ------------------------------------------------------------
# This creates a ZIP file from the contents of ./src directory.
# Terraform automatically regenerates it when source changes.
# Lambda requires deployment as a ZIP archive.

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/src"          # Folder containing app.py
  output_path = "${path.module}/build/ingest.zip"  # Where ZIP is written
}

# ------------------------------------------------------------
# IAM Role for Lambda
# ------------------------------------------------------------
# Lambda must assume an IAM role to access AWS services.
# This defines a role trusted by Lambda service.

resource "aws_iam_role" "lambda_role" {

  # Naming explicitly for clarity in AWS Console
  name = "laro-tacho-dev-ingest-role"

  # Trust policy: allows Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# ------------------------------------------------------------
# Attach Basic Logging Policy
# ------------------------------------------------------------
# AWS managed policy that allows:
# - Creating CloudWatch log groups
# - Writing logs
# Without this, Lambda would fail silently.

resource "aws_iam_role_policy_attachment" "basic_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ------------------------------------------------------------
# Lambda Function Resource
# ------------------------------------------------------------
# This creates the actual Lambda function in AWS.

resource "aws_lambda_function" "ingest" {

  # Name comes from variable
  function_name = var.lambda_name

  # IAM role created earlier
  role = aws_iam_role.lambda_role.arn

  # Runtime environment
  runtime = "python3.12"

  # File that contains lambda_handler
  handler = "app.lambda_handler"

  # Deployment package
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Basic execution settings
  timeout     = 15
  memory_size = 128

  # Environment variables injected into Lambda
  environment {
    variables = {
      LEDGER_TABLE = var.ledger_table_name
      RAW_BUCKET   = var.raw_bucket_name
    }
  }
}