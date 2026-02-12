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

output "raw_bucket_name" {
  value = module.raw_store.bucket_name
}

output "raw_bucket_arn" {
  value = module.raw_store.bucket_arn
}
