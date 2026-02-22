variable "name" {
  description = "Name of the DynamoDB ingestion ledger table"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the table"
  type        = map(string)
  default     = {}
}