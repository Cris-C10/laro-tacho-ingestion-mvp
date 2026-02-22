resource "aws_dynamodb_table" "this" {
  name         = var.name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "object_key"

  attribute {
    name = "object_key"
    type = "S"
  }

  attribute {
    name = "received_at"
    type = "S"
  }

  global_secondary_index {
    name            = "received_at_index"
    hash_key        = "received_at"
    projection_type = "ALL"
  }

  tags = var.tags
}