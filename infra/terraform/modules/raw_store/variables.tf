variable "name" {
  description = "Name of the raw S3 bucket"
  type        = string
}

variable "force_destroy" {
  description = "If true, allow Terraform to delete the bucket even if it contains objects (dev only)."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
