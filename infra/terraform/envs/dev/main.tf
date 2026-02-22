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