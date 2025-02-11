module "domain" {
  source = "../../../../modules/intelica-module-opensearch/domain"


  name                 = var.name
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.kms_key_arn
  instance_type        = var.instance_type
  engine_version       = var.engine_version
  storage_size       = var.storage_size
  instance_count       = var.instance_count
}