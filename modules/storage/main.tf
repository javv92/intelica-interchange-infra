module "enriched" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-s3//bucket"

  name                 = "enriched"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.key_arn
}
module "landing" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-s3//bucket"

  name                 = "landing"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.key_arn
}
module "log" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-s3//bucket"

  name                 = "log"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.key_arn
}
module "operational" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-s3//bucket"

  name                 = "operational"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.key_arn
}
module "row" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-s3//bucket"

  name                 = "row"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.key_arn
}
module "structured" {
  source = "git@github.com:ITL-ORG-INFRA/intelica-module-s3//bucket"

  name                 = "structured"
  stack_number         = var.stack_number
  prefix_resource_name = var.prefix_resource_name
  kms_key_arn          = var.key_arn
}